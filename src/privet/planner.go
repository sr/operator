package privet

import "time"

type PlanTestExecution struct {
	File string `json:"file"`

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

type PlanCreationOpts struct {
	TestFiles           []*TestFile
	PreviousResults     TestRunResults
	NumWorkers          int
	TargetDuration      time.Duration
	DefaultTestDuration time.Duration
}

// newPlanWorker creates a new PlanWorker with the first test batch initialized
func newPlanWorker() *PlanWorker {
	return &PlanWorker{
		TestBatches: []*PlanTestBatch{
			&PlanTestBatch{},
		},
	}
}

func CreatePlan(opts *PlanCreationOpts) (*Plan, error) {
	plan := &Plan{
		Workers: make(map[int]*PlanWorker),
	}

	currentWorkerIndex := 0
	for _, testFile := range opts.TestFiles {
		currentWorker, ok := plan.Workers[currentWorkerIndex]
		if !ok {
			currentWorker = newPlanWorker()
			plan.Workers[currentWorkerIndex] = currentWorker
		}
		currentBatch := currentWorker.TestBatches[len(currentWorker.TestBatches)-1]

		testExecution := &PlanTestExecution{
			File: testFile.File,
		}
		currentBatch.TestExecutions = append(currentBatch.TestExecutions, testExecution)

		currentWorkerIndex++
	}

	return plan, nil
}
