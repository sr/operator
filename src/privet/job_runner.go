package privet

import (
	"bytes"
	"crypto/rand"
	"encoding/hex"
	"fmt"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"syscall"
	"time"

	"golang.org/x/net/context"
)

const (
	JobRunnerRetries    = 10
	JobRunnerRetryDelay = 2 * time.Second
)

type JobRunner struct {
	BatchUnits int32

	runnerID        string
	privetDir       string
	masterClient    JobMasterClient
	currentResultID int
}

func NewJobRunner(privetDir string, masterClient JobMasterClient) *JobRunner {
	runner := &JobRunner{
		BatchUnits: 1,

		privetDir:       privetDir,
		masterClient:    masterClient,
		currentResultID: 0,
	}
	runner.generateRunnerID()

	return runner
}

func (r *JobRunner) generateRunnerID() {
	hostname, err := os.Hostname()
	if err != nil {
		hostname = "invalidhost"
	}

	randBytes := make([]byte, 8) // 64 bits
	if _, err := rand.Read(randBytes); err != nil {
		log.Printf("unable to generate random bytes for runner id: %v", err)
	}

	r.runnerID = fmt.Sprintf("%s:%s", hostname, hex.EncodeToString(randBytes))
}

func (r *JobRunner) RunStartupHook() error {
	return r.runOptionalHook("runner-hook-startup")
}

func (r *JobRunner) RunCleanupHook() error {
	return r.runOptionalHook("runner-hook-Cleanup")
}

func (r *JobRunner) runOptionalHook(hook string) error {
	path := filepath.Join(r.privetDir, hook)
	_, err := os.Stat(path)
	if os.IsNotExist(err) {
		return nil
	}

	cmd := &exec.Cmd{
		Path:   path,
		Stdin:  nil,
		Stdout: os.Stdout,
		Stderr: os.Stderr,
		Env: []string{
			fmt.Sprintf("PRIVET_RUNNER_ID=%s", r.runnerID),
		},
	}

	return cmd.Run()
}

func (r *JobRunner) PopAndRunUnits() (done bool, err error) {
	popUnitsReq := &PopUnitsRequest{
		RunnerId:       r.runnerID,
		UnitsRequested: r.BatchUnits,
	}

	popUnitsResp, err := r.masterClient.PopUnits(context.Background(), popUnitsReq)
	if err != nil {
		return false, err
	} else if len(popUnitsResp.Units) == 0 {
		return true, err
	}

	unitsData := make([]string, 0, len(popUnitsResp.Units))
	for _, unit := range popUnitsResp.Units {
		unitsData = append(unitsData, unit.Data)
	}

	unitResult, err := r.invokeUnits(unitsData)
	if err != nil {
		// TODO: We've now claimed units we'll never complete.
		return false, err
	}

	additionalResultsPresent, additionalResult, err := r.captureAdditionalResults(unitsData)
	if err != nil {
		// TODO: We've now claimed units we'll never complete.
		return false, err
	} else if !additionalResultsPresent {
		// We can't send a null value back over grpc
		additionalResult = &CommandResult{
			ExitCode: 0,
			Output:   []byte{},
		}
	}

	r.currentResultID = r.currentResultID + 1
	completionReq := &ReportUnitsCompletionRequest{
		RunnerId:                r.runnerID,
		ResultId:                fmt.Sprintf("%s:%d", r.runnerID, r.currentResultID),
		Units:                   popUnitsResp.Units,
		UnitResult:              unitResult,
		AdditionalResultPresent: additionalResultsPresent,
		AdditionalResult:        additionalResult,
	}

	retries := JobRunnerRetries
	for {
		_, err = r.masterClient.ReportUnitsCompletion(context.Background(), completionReq)
		if err != nil {
			retries = retries - 1
			if retries > 0 {
				log.Printf("got error, retrying after delay: %v", err)
				time.Sleep(JobRunnerRetryDelay)
			} else {
				return false, err
			}
		} else {
			return false, err
		}
	}
}

func (r *JobRunner) invokeUnits(unitsData []string) (*CommandResult, error) {
	buf := new(bytes.Buffer)
	path := filepath.Join(r.privetDir, "runner-run-units")

	log.Printf("invoking units: %v", unitsData)
	cmd := &exec.Cmd{
		Path:   path,
		Args:   append([]string{path}, unitsData...),
		Stdin:  nil,
		Stdout: buf,
		Stderr: buf,
		Env: []string{
			fmt.Sprintf("PRIVET_RUNNER_ID=%s", r.runnerID),
		},
	}

	err := cmd.Run()
	exitCode := 0
	if exiterr, ok := err.(*exec.ExitError); ok {
		// The command exited with a non-zero code
		status := exiterr.Sys().(syscall.WaitStatus)
		exitCode = status.ExitStatus()
	} else if err != nil {
		return nil, err
	}

	log.Printf("finished units %v, exited with %v", unitsData, exitCode)
	return &CommandResult{
		ExitCode: int32(exitCode),
		Output:   buf.Bytes(),
	}, nil
}

func (r *JobRunner) captureAdditionalResults(unitsData []string) (bool, *CommandResult, error) {
	path := filepath.Join(r.privetDir, "runner-additional-results")
	_, err := os.Stat(path)
	if os.IsNotExist(err) {
		return false, nil, nil
	}

	buf := new(bytes.Buffer)
	cmd := &exec.Cmd{
		Path:   path,
		Stdin:  nil,
		Stdout: buf,
		Stderr: buf,
		Env: []string{
			fmt.Sprintf("PRIVET_RUNNER_ID=%s", r.runnerID),
		},
	}

	err = cmd.Run()
	exitCode := 0
	if exiterr, ok := err.(*exec.ExitError); ok {
		// The command exited with a non-zero code
		status := exiterr.Sys().(syscall.WaitStatus)
		exitCode = status.ExitStatus()
	} else if err != nil {
		return false, nil, err
	}

	return true, &CommandResult{
		ExitCode: int32(exitCode),
		Output:   buf.Bytes(),
	}, nil
}
