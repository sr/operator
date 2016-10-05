package privet

import (
	"bytes"
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"sync"
)

type TestBatchExecutor func(opts *PlanExecutionOpts, parallelIndex int, sequenceIndex int, batch *PlanTestBatch) (bool, error)

var execTestExecutor = func(opts *PlanExecutionOpts, parallelIndex int, sequenceIndex int, batch *PlanTestBatch) (bool, error) {
	fullCommandPath, err := exec.LookPath(opts.CommandPath)
	if err != nil {
		return false, err
	}

	env := []string{}
	if opts.Env != nil {
		env = append(env, opts.Env...)
	}
	env = append(env, []string{
		fmt.Sprintf("PRIVET_WORKER=%d", opts.Worker),
		fmt.Sprintf("PRIVET_PARALLEL_INDEX=%d", parallelIndex),
		fmt.Sprintf("PRIVET_SEQUENCE_INDEX=%d", sequenceIndex),
	}...)

	in := new(bytes.Buffer)
	encoder := json.NewEncoder(in)
	if err := encoder.Encode(batch); err != nil {
		return false, err
	}

	cmd := &exec.Cmd{
		Path:   fullCommandPath,
		Args:   []string{fullCommandPath},
		Env:    env,
		Stdin:  in,
		Stdout: os.Stdout,
		Stderr: os.Stderr,
	}

	err = cmd.Run()
	if _, ok := err.(*exec.ExitError); ok {
		// The command exited non-zero
		return false, nil
	} else if err != nil {
		return false, err
	} else {
		return true, nil
	}
}

type PlanExecutionOpts struct {
	// CommandPath is the path of the command to run as part of plan
	// execution.
	//
	// The command will receive the JSON representation of the test batch as
	// standard in.
	CommandPath string

	// Worker is the index in the plan that this worker will consume as its
	// queue.
	Worker int

	// Parallelism is the number of processes that are spun up to process
	// this worker's queue. Parallelism adds an additional way to work to be
	// balanced as evenly as possible. The environment variable
	// PRIVET_PARALLEL_INDEX will be set to a counter starting at 0 to uniquely
	// identify each parallel process.
	Parallelism int

	Env []string

	TestBatchExecutor TestBatchExecutor
}

// ExecutePlan executes the specified test plan. It returns true if the test
// plan executed successfully; otherwise, false. An error is returned only if an
// egregious error happens while executing the plan. An error will not be present
// if one of the plan command invocation returns non-zero.
func ExecutePlan(plan *Plan, opts *PlanExecutionOpts) (bool, error) {
	executor := opts.TestBatchExecutor
	if executor == nil {
		executor = execTestExecutor
	}

	parallelism := opts.Parallelism
	if parallelism <= 0 {
		parallelism = 1
	}

	worker, ok := plan.Workers[opts.Worker]
	if !ok {
		fmt.Fprintf(os.Stderr, "worker %d not found in plan; nothing to do", opts.Worker)
		return true, nil
	}

	batches := make(chan *PlanTestBatch)
	go func() {
		for _, batch := range worker.TestBatches {
			batches <- batch
		}
		close(batches)
	}()

	var wg sync.WaitGroup
	var overallError error
	overallSuccess := true
	for i := 0; i < parallelism; i++ {
		wg.Add(1)
		go func(parallelIndex int) {
			sequenceIndex := 0
			for batch := range batches {
				success, err := executor(opts, parallelIndex, sequenceIndex, batch)
				if err != nil {
					overallError = err
				} else if !success {
					overallSuccess = false
				}
				sequenceIndex++
			}
			wg.Done()
		}(i)
	}

	wg.Wait()
	return overallSuccess, overallError
}
