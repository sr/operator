package privet

import (
	"sort"
	"time"
)

type PlanTestExecution struct {
	Filename string `json:"filename"`

	ExpectedDuration time.Duration `json:"-"`

	// If present, Privet has determined that only the specified test cases
	// should be run because running the entire file would take much longer
	// than the TargetDuration. If not present, the entire file should be
	// run without a filter.
	TestCaseNames []string `json:"test_case_names,omitempty"`
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
	Filename    string `json:"filename"`
	Suite       string `json:"suite"`
	Fingerprint string `json:"fingerprint"`
}

type PlanCreationOpts struct {
	TestFiles           []*TestFile
	PreviousResults     TestRunResults
	NumWorkers          int
	TargetDuration      time.Duration
	DefaultTestDuration time.Duration
}

// https://talks.golang.org/2014/go4gophers.slide#15
type testFileSlice []*TestFile

func (s testFileSlice) Len() int      { return len(s) }
func (s testFileSlice) Swap(i, j int) { s[i], s[j] = s[j], s[i] }

type bySuite struct{ testFileSlice }

func (s bySuite) Less(i, j int) bool { return s.testFileSlice[i].Suite < s.testFileSlice[j].Suite }

func newPlanTestBatch() *PlanTestBatch {
	return &PlanTestBatch{
		TestExecutions: []*PlanTestExecution{},
	}
}

func CreatePlan(opts *PlanCreationOpts) (*Plan, error) {
	plan := &Plan{
		Workers: make(map[int]*PlanWorker),
	}

	sort.Sort(bySuite{opts.TestFiles})

	batches := []*PlanTestBatch{}
	currentSuite := ""
	currentBatchIndex := 0
	currentBatchDuration := time.Duration(0)
	totalRemainingDuration := time.Duration(0)
	for _, testFile := range opts.TestFiles {
		var testResult *TestFileResult
		if opts.PreviousResults != nil {
			testResult = opts.PreviousResults[testFile.Filename]
		}

		currentTestFileDuration := opts.DefaultTestDuration
		if testResult != nil {
			currentTestFileDuration = testResult.Duration
		}

		// If this test file by itself exceeds TargetDuration and the
		// fingerprint matches, we use the previous test result information
		// to bust it up into ranges of test cases within the file
		if currentTestFileDuration > opts.TargetDuration &&
			testResult != nil && testResult.TestCases != nil &&
			testResult.Fingerprint != "" && testResult.Fingerprint == testFile.Fingerprint {
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
						Filename:         testFile.Filename,
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
			if currentBatchDuration > 0 &&
				(currentSuite != "" && currentSuite != testFile.Suite ||
					currentBatchDuration+currentTestFileDuration > opts.TargetDuration) {
				currentBatchIndex++
				currentBatchDuration = time.Duration(0)
			}
			for currentBatchIndex >= len(batches) {
				batches = append(batches, newPlanTestBatch())
			}

			currentBatch := batches[currentBatchIndex]
			currentBatch.TestExecutions = append(currentBatch.TestExecutions, &PlanTestExecution{
				Filename:         testFile.Filename,
				ExpectedDuration: currentTestFileDuration,
			})

			currentBatchDuration += currentTestFileDuration
			totalRemainingDuration += currentTestFileDuration
			currentSuite = testFile.Suite
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
