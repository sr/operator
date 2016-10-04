package privet

import (
	"bytes"
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
)

type TestBatchExecutor func(opts *PlanExecutionOpts, batchIndex int, batch *PlanTestBatch) (bool, error)

var execTestExecutor = func(opts *PlanExecutionOpts, batchIndex int, batch *PlanTestBatch) (bool, error) {
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
		fmt.Sprintf("PRIVET_BATCH_INDEX=%d", batchIndex),
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
	// The command will receive the JSOn representation of the test batch as
	// standard in.
	CommandPath string

	Worker int

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

	worker, ok := plan.Workers[opts.Worker]
	if !ok {
		return false, fmt.Errorf("worker %d not found in plan", opts.Worker)
	}

	overallSuccess := true
	for batchIndex, batch := range worker.TestBatches {
		success, err := executor(opts, batchIndex, batch)
		if err != nil {
			return false, err
		} else if !success {
			overallSuccess = false
		}
	}
	return overallSuccess, nil
}
