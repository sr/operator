package privet_test

import (
	"fmt"
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
				fmt.Printf("%#v\n", execution)
				fmt.Printf("%#v\n", expectedExecution)
				if !reflect.DeepEqual(execution, expectedExecution) {
					t.Fatalf("expected worker %d, batch %d, test execution %d to be %#v, but was %#v", workerIndex, batchIndex, executionIndex, expectedExecution, execution)
				}
			}
		}
	}
}

func TestBasicPlan(t *testing.T) {
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
		NumWorkers:          3,
		TargetDuration:      1 * time.Minute,
		DefaultTestDuration: 1 * time.Minute,
	}

	expectedPlan := &privet.Plan{
		Workers: map[int]*privet.PlanWorker{
			0: &privet.PlanWorker{
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
			1: &privet.PlanWorker{
				TestBatches: []*privet.PlanTestBatch{
					{
						TestExecutions: []*privet.PlanTestExecution{
							{
								File: "/test2.php",
							},
						},
					},
				},
			},
			2: &privet.PlanWorker{
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

// func TestPlanWithPreviousResults(t *testing.T) {
//	planOpts := &privet.PlanCreationOpts{
//		TestFiles: []*privet.TestFile{
//			{
//				File:  "/test1.php",
//				Suite: "suite1",
//			},
//			{
//				File:  "/test2.php",
//				Suite: "suite1",
//			},
//			{
//				File:  "/test3.php",
//				Suite: "suite1",
//			},
//		},
//		PreviousResults: []*privet.TestFileResult{
//			{
//				{
//					Name:     "Test1",
//					File:     "/app/test1.class.php",
//					Duration: 1 * time.Minute,
//				},
//				{
//					Name:     "Test2",
//					Filename: "/app/test2.class.php",
//					Time:     30 * time.Second,
//				},
//				{
//					Name:     "test3",
//					Filename: "/app/test3.class.php",
//					Time:     30 * time.Second,
//				},
//			},
//		},
//		NumWorkers:          2,
//		TargetDuration:      1 * time.Minute,
//		DefaultTestDuration: 1 * time.Minute,
//	}

//	plan, err := planner.Plan()
//	if err != nil {
//		t.Error(err)
//	}
//	if len(plan.Workers) != 2 {
//		t.Errorf("expected len(plan.Workers) to be %d, but was %d", 2, len(plan.Workers))
//	}

//	worker0 := plan.Workers[0]
//	if len(worker0) != 1 {
//		t.Errorf("expected worker 0 to be assigned %d tasks, but was assigned %d", 1, len(worker0))
//	}
//	worker1 := plan.Workers[1]
//	if len(worker1) != 2 {
//		t.Errorf("expected worker 1 to be assigned %d tasks, but was assigned %d", 2, len(worker1))
//	}
// }
