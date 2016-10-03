package privet

import (
	"crypto/sha256"
	"encoding/hex"
	"io"
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
	defer file.Close()

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

		currentTestFileDuration := expectedTestDurationOrDefault(testResult, fingerprinter, opts.DefaultTestDuration)
		if currentBatchDuration+currentTestFileDuration > opts.TargetDuration {
			currentBatchIndex++
			currentBatchDuration = time.Duration(0)
		}

		for currentBatchIndex >= len(batches) {
			batches = append(batches, &PlanTestBatch{
				TestExecutions: []*PlanTestExecution{},
			})
		}
		currentBatch := batches[currentBatchIndex]
		currentBatch.TestExecutions = append(currentBatch.TestExecutions, &PlanTestExecution{
			File:             testFile.File,
			ExpectedDuration: currentTestFileDuration,
		})

		currentBatchDuration += currentTestFileDuration
		totalRemainingDuration += currentTestFileDuration
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

func expectedTestDurationOrDefault(testResult *TestFileResult, fingerprinter Fingerprinter, defaultDuration time.Duration) time.Duration {
	if testResult != nil {
		fingerprint, err := fingerprinter(testResult.File)
		if err != nil || fingerprint != testResult.Fingerprint {
			return defaultDuration
		} else {
			return testResult.Duration
		}
	} else {
		return defaultDuration
	}
}
