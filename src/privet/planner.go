package privet

import (
	"crypto/sha256"
	"encoding/hex"
	"io"
	"log"
	"os"
	"time"
)

type PlanTestExecution struct {
	File string `json:"file"`

	ExpectedDuration time.Duration `json:"-"`

	// If present, Privet has determined that only the specified test cases
	// should be run because running the entire file would take much longer
	// than the TargetDuration. If not present, the entire file should be
	// run without a filter.
	TestCaseNames []string `json:"test_case_names"`
}

// PlanTestBatch is a set of test files and test case names that can be executed
// in one run of the test runner. These are tests that are chunked together because
// they are 1) in the same suite 2) fit into (roughly) a TargetDuration amount of
// time
type PlanTestBatch struct {
	TestExecutions []*PlanTestExecution `json:"test_executions"`
}

type PlanWorker struct {
	TestBatches []*PlanTestBatch `json:"test_batches"`
}

type Plan struct {
	Workers map[int]*PlanWorker `json:"workers"`
}

type TestFile struct {
	File        string
	Suite       string
	Fingerprint string
}

// Fingerprinter is expected to return a collision-resistent hash of the file
// given as its argument.
type Fingerprinter func(string) (string, error)

var sha256Fingerprinter = func(filename string) (string, error) {
	file, err := os.Open(filename)
	if err != nil {
		return "", err
	}
	defer func() { _ = file.Close() }()

	hash := sha256.New()
	if _, err := io.Copy(hash, file); err != nil {
		return "", err
	}

	return hex.EncodeToString(hash.Sum(nil)), nil
}

type PlanCreationOpts struct {
	TestFiles           []*TestFile
	PreviousResults     TestRunResults
	NumWorkers          int
	TargetDuration      time.Duration
	DefaultTestDuration time.Duration

	// Fingerprinter specifies a function to generate a collision-resistent
	// hash of the given test file. If left unspecified, a SHA256 hash is used.
	Fingerprinter Fingerprinter
}

func newPlanTestBatch() *PlanTestBatch {
	return &PlanTestBatch{
		TestExecutions: []*PlanTestExecution{},
	}
}

func CreatePlan(opts *PlanCreationOpts) (*Plan, error) {
	fingerprinter := opts.Fingerprinter
	if fingerprinter == nil {
		fingerprinter = sha256Fingerprinter
	}

	plan := &Plan{
		Workers: make(map[int]*PlanWorker),
	}

	batches := []*PlanTestBatch{}
	currentBatchIndex := 0
	currentBatchDuration := time.Duration(0)
	totalRemainingDuration := time.Duration(0)
	for _, testFile := range opts.TestFiles {
		var testResult *TestFileResult
		if opts.PreviousResults != nil {
			testResult = opts.PreviousResults[testFile.File]
		}

		currentTestFileDuration := opts.DefaultTestDuration
		if testResult != nil {
			currentTestFileDuration = testResult.Duration
		}

		// If this test file by itself exceeds TargetDuration and the
		// fingerprint matches, we use the previous test result information
		// to bust it up into ranges of test cases within the file
		if currentTestFileDuration > opts.TargetDuration &&
			testResult != nil && testResult.TestCases != nil && fingerprintMatches(testResult, fingerprinter) {
			executions := []*PlanTestExecution{}
			currentExecutionIndex := 0
			currentExecutionDuration := time.Duration(0)
			for _, testCase := range testResult.TestCases {
				currentCaseDuration := testCase.Duration
				if currentExecutionDuration > 0 && currentExecutionDuration+currentCaseDuration > opts.TargetDuration {
					currentExecutionIndex++
					currentExecutionDuration = time.Duration(0)
				}
				for currentExecutionIndex >= len(executions) {
					executions = append(executions, &PlanTestExecution{
						File:             testFile.File,
						ExpectedDuration: time.Duration(0),
						TestCaseNames:    []string{},
					})
				}
				currentTestExecution := executions[currentExecutionIndex]

				currentTestExecution.TestCaseNames = append(currentTestExecution.TestCaseNames, testCase.Name)
				currentTestExecution.ExpectedDuration += testCase.Duration

				currentExecutionDuration += testCase.Duration
			}

			// With the batches of _test cases_ created, create _test_ batches of them
			// And first of all, make sure we start in our own batch.
			if currentBatchDuration > 0 {
				currentBatchIndex++
				currentBatchDuration = time.Duration(0)
			}

			for _, execution := range executions {
				for currentBatchIndex >= len(batches) {
					batches = append(batches, newPlanTestBatch())
				}
				currentBatch := batches[currentBatchIndex]

				currentBatch.TestExecutions = []*PlanTestExecution{execution}

				currentBatchDuration += execution.ExpectedDuration
				totalRemainingDuration += execution.ExpectedDuration

				currentBatchIndex++
				currentBatchDuration = time.Duration(0)
			}
		} else {
			if currentBatchDuration > 0 && currentBatchDuration+currentTestFileDuration > opts.TargetDuration {
				currentBatchIndex++
				currentBatchDuration = time.Duration(0)
			}
			for currentBatchIndex >= len(batches) {
				batches = append(batches, newPlanTestBatch())
			}

			currentBatch := batches[currentBatchIndex]
			currentBatch.TestExecutions = append(currentBatch.TestExecutions, &PlanTestExecution{
				File:             testFile.File,
				ExpectedDuration: currentTestFileDuration,
			})

			currentBatchDuration += currentTestFileDuration
			totalRemainingDuration += currentTestFileDuration
		}
	}

	approxDurationPerRemainingWorker := totalRemainingDuration / time.Duration(opts.NumWorkers)
	currentWorkerIndex := 0
	currentWorkerDuration := time.Duration(0)
	for _, batch := range batches {
		currentBatchDuration = time.Duration(0)
		for _, execution := range batch.TestExecutions {
			currentBatchDuration += execution.ExpectedDuration
		}
		if _, ok := plan.Workers[currentWorkerIndex]; ok &&
			currentWorkerDuration+currentBatchDuration > approxDurationPerRemainingWorker {
			currentWorkerIndex++
			currentWorkerDuration = 0
			approxDurationPerRemainingWorker = totalRemainingDuration / time.Duration(opts.NumWorkers-currentWorkerIndex)
		}

		currentWorker, ok := plan.Workers[currentWorkerIndex]
		if !ok {
			currentWorker = &PlanWorker{
				TestBatches: []*PlanTestBatch{},
			}
			plan.Workers[currentWorkerIndex] = currentWorker
		}

		currentWorker.TestBatches = append(currentWorker.TestBatches, batch)

		currentWorkerDuration += currentBatchDuration
		totalRemainingDuration -= currentBatchDuration
	}

	return plan, nil
}

func fingerprintMatches(testResult *TestFileResult, fingerprinter Fingerprinter) bool {
	fingerprint, err := fingerprinter(testResult.File)
	if err != nil {
		log.Printf("unable to fingerprint file %s: %v", testResult.File, err)
		return false
	}

	return fingerprint == testResult.Fingerprint
}
