package privet_test

import (
	"privet"
	"reflect"
	"testing"
	"time"
)

func expectPlan(t *testing.T, opts *privet.PlanCreationOpts, expectedPlan *privet.Plan) {
	plan, err := privet.CreatePlan(opts)
	if err != nil {
		t.Fatal(err)
	}

	if len(plan.Workers) != len(expectedPlan.Workers) {
		t.Fatalf("expected plan to have %d workers, but got %d", len(expectedPlan.Workers), len(plan.Workers))
	}
	for i := range expectedPlan.Workers {
		if _, ok := plan.Workers[i]; !ok {
			t.Fatalf("expected plan to have worker %d, but was missing", i)
		}
	}

	// A plan has many workers
	// A worker has many batches
	// A batch has many test executions
	for workerIndex, worker := range plan.Workers {
		expectedWorker := expectedPlan.Workers[workerIndex]
		if len(worker.TestBatches) != len(expectedWorker.TestBatches) {
			t.Fatalf("expected plan worker %d to have %d batches, but got %d", workerIndex, len(expectedWorker.TestBatches), len(worker.TestBatches))
		}

		for batchIndex, batch := range worker.TestBatches {
			expectedBatch := expectedWorker.TestBatches[batchIndex]
			if len(batch.TestExecutions) != len(expectedBatch.TestExecutions) {
				t.Fatalf("expected worker %d, batch %d to have %d executions, but got %d", workerIndex, batchIndex, len(expectedBatch.TestExecutions), len(batch.TestExecutions))

			}

			for executionIndex, execution := range batch.TestExecutions {
				expectedExecution := expectedBatch.TestExecutions[executionIndex]
				if execution.File != expectedExecution.File {
					t.Fatalf("expected worker %d, batch %d, test execution %d to have file %v, but was %v", workerIndex, batchIndex, executionIndex, expectedExecution.File, execution.File)
				}
				if !reflect.DeepEqual(execution.TestCaseNames, expectedExecution.TestCaseNames) {
					t.Fatalf("expected worker %d, batch %d, test execution %d to have test case names %v, but was %v", workerIndex, batchIndex, executionIndex, expectedExecution.TestCaseNames, execution.TestCaseNames)
				}
			}
		}
	}
}

func TestBasicPlanChunkedByDefaultDuration(t *testing.T) {
	// If each test is expected to take 30 seconds by default, and the
	// target duration is 1 minute, the first two tests should get chunked into
	// the first worker
	planOpts := &privet.PlanCreationOpts{
		TestFiles: []*privet.TestFile{
			{
				File:  "/test1.php",
				Suite: "suite1",
			},
			{
				File:  "/test2.php",
				Suite: "suite1",
			},
			{
				File:  "/test3.php",
				Suite: "suite1",
			},
		},
		PreviousResults:     nil,
		NumWorkers:          2,
		TargetDuration:      1 * time.Minute,
		DefaultTestDuration: 30 * time.Second,
	}

	expectedPlan := &privet.Plan{
		Workers: map[int]*privet.PlanWorker{
			0: {
				TestBatches: []*privet.PlanTestBatch{
					{
						TestExecutions: []*privet.PlanTestExecution{
							{
								File: "/test1.php",
							},
							{
								File: "/test2.php",
							},
						},
					},
				},
			},
			1: {
				TestBatches: []*privet.PlanTestBatch{
					{
						TestExecutions: []*privet.PlanTestExecution{
							{
								File: "/test3.php",
							},
						},
					},
				},
			},
		},
	}

	expectPlan(t, planOpts, expectedPlan)
}

func TestBasicPlanChunkedByDurationFromPreviousResults(t *testing.T) {
	// The planner should take into account previous results information, if
	// present
	planOpts := &privet.PlanCreationOpts{
		TestFiles: []*privet.TestFile{
			{
				File:  "/test1.php",
				Suite: "suite1",
			},
			{
				File:  "/test2.php",
				Suite: "suite1",
			},
			{
				File:  "/test3.php",
				Suite: "suite1",
			},
		},
		PreviousResults: privet.TestRunResults{
			"/test1.php": {
				Name:        "Test1",
				File:        "/test1.php",
				Fingerprint: "abc123",
				Duration:    1 * time.Minute,
			},
		},
		Fingerprinter: func(string) (string, error) {
			return "abc123", nil
		},
		NumWorkers:          2,
		TargetDuration:      1 * time.Minute,
		DefaultTestDuration: 30 * time.Second,
	}

	expectedPlan := &privet.Plan{
		Workers: map[int]*privet.PlanWorker{
			0: {
				TestBatches: []*privet.PlanTestBatch{
					{
						TestExecutions: []*privet.PlanTestExecution{
							{
								File: "/test1.php",
							},
						},
					},
				},
			},
			1: {
				TestBatches: []*privet.PlanTestBatch{
					{
						TestExecutions: []*privet.PlanTestExecution{
							{
								File: "/test2.php",
							},
							{
								File: "/test3.php",
							},
						},
					},
				},
			},
		},
	}

	expectPlan(t, planOpts, expectedPlan)
}
