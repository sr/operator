package privet

import "time"

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

type PlanCreationOpts struct {
	TestFiles           []*TestFile
	PreviousResults     TestRunResults
	NumWorkers          int
	TargetDuration      time.Duration
	DefaultTestDuration time.Duration
}

func CreatePlan(opts *PlanCreationOpts) (*Plan, error) {
	plan := &Plan{
		Workers: make(map[int]*PlanWorker),
	}

	batches := []*PlanTestBatch{}
	currentBatchIndex := 0
	currentBatchDuration := time.Duration(0)
	totalRemainingDuration := time.Duration(0)
	for _, testFile := range opts.TestFiles {
		currentTestFileDuration := opts.DefaultTestDuration
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
