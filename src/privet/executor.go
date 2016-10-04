package privet

import (
	"fmt"
	"os"
	"os/exec"
	"strings"
)

type TestBatchExecutor func(opts *PlanExecutionOpts, batchIndex int, batch *PlanTestBatch) (bool, error)

var execTestExecutor = func(opts *PlanExecutionOpts, batchIndex int, batch *PlanTestBatch) (bool, error) {
	fullCommandPath, err := exec.LookPath(opts.CommandPath)
	if err != nil {
		return false, err
	}

	testFiles := []string{}
	testCaseNames := []string{}
	for _, execution := range batch.TestExecutions {
		testFiles = append(testFiles, execution.Filename)
		testCaseNames = append(testCaseNames, execution.TestCaseNames...)
	}

	env := []string{}
	if opts.Env != nil {
		env = append(env, opts.Env...)
	}
	env = append(env, []string{
		fmt.Sprintf("PRIVET_TEST_BATCH=%d", batchIndex),
		fmt.Sprintf("PRIVET_WORKER=%d", opts.Worker),
	}...)
	if len(testFiles) > 0 {
		env = append(env, fmt.Sprintf("PRIVET_TEST_FILES=%s", strings.Join(testFiles, "\x00")))
	}
	if len(testCaseNames) > 0 {
		env = append(env, fmt.Sprintf("PRIVET_TEST_CASE_NAMES=%s", strings.Join(testCaseNames, "\x00")))
	}

	cmd := &exec.Cmd{
		Path:   fullCommandPath,
		Env:    env,
		Stdin:  nil,
		Stdout: os.Stdout,
		Stderr: os.Stderr,
	}
	fmt.Printf("%#v\n", cmd)

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
	// The command will receive two environment variables which it should
	// use to execute the requested test case(s):
	// * PRIVET_TEST_FILES: Test files (separated by \0)
	// * PRIVET_TEST_CASE_NAMES: Test cases (separated by \0)
	// * PRIVET_TEST_BATCH: Strictly increasing integer identifier of the
	//                      test batch
	// * PRIVET_WORKER: Worker identifier
	//
	// If PRIVET_TEST_CASE_NAMES is specified, only one test file will be
	// present in PRIVET_TEST_FILES.
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
