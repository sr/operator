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

	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"

	"golang.org/x/net/context"
)

const (
	JobRunnerRetries       = 4
	JobRunnerRetryDelay    = 2 * time.Second
	JobRunnerClientTimeout = 10 * time.Second
)

type JobRunner struct {
	ApproximateBatchDurationInSeconds float64
	EnvVars                           []string

	runnerID        string
	privetDir       string
	masterClient    JobMasterClient
	currentResultID int
}

func NewJobRunner(privetDir string, masterClient JobMasterClient) *JobRunner {
	runner := &JobRunner{
		ApproximateBatchDurationInSeconds: 0,

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
	return r.runOptionalHook("runner-hook-cleanup")
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
		Env: append(retrieveEnvVars(r.EnvVars), []string{
			fmt.Sprintf("PRIVET_RUNNER_ID=%s", r.runnerID),
		}...),
	}

	return cmd.Run()
}

// NotifyQueueEmpty closes ch when the queue is determined to be empty
func (r *JobRunner) NotifyQueueEmpty(ch chan<- bool) {
	for {
		ctx, cancel := context.WithTimeout(context.Background(), JobRunnerClientTimeout)
		queueStats, err := r.masterClient.GetQueueStatistics(ctx, &QueueStatisticsRequest{})
		cancel()

		if err != nil && grpc.Code(err) == codes.DeadlineExceeded {
			// In all liklihood, the Privet master has shut down completely because
			// the queue is empty.
			close(ch)
			break
		} else if err != nil {
			log.Printf("error checking queue stats; retrying in a few seconds: %v", err)
		} else if queueStats.UnitsInQueue == 0 {
			close(ch)
			break
		}
		time.Sleep(5 * time.Second)
	}
}

func (r *JobRunner) PopUnits() ([]*Unit, error) {
	popUnitsReq := &PopUnitsRequest{
		RunnerId: r.runnerID,
		ApproximateBatchDurationInSeconds: r.ApproximateBatchDurationInSeconds,
	}

	ctx, cancel := context.WithTimeout(context.Background(), JobRunnerClientTimeout)
	defer cancel()
	popUnitsResp, err := r.masterClient.PopUnits(ctx, popUnitsReq)

	if err != nil {
		return nil, err
	}
	return popUnitsResp.Units, nil
}

func (r *JobRunner) RunUnits(units []*Unit) error {
	unitsData := make([]string, 0, len(units))
	for _, unit := range units {
		unitsData = append(unitsData, unit.Data)
	}

	unitResult, err := r.invokeUnits(unitsData)
	if err != nil {
		// TODO: We've now claimed units we'll never complete.
		return err
	}

	additionalResultsPresent, additionalResult, err := r.captureAdditionalResults(unitsData)
	if err != nil {
		// TODO: We've now claimed units we'll never complete.
		return err
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
		Units:                   units,
		UnitResult:              unitResult,
		AdditionalResultPresent: additionalResultsPresent,
		AdditionalResult:        additionalResult,
	}

	retries := JobRunnerRetries
	for {
		ctx, cancel := context.WithTimeout(context.Background(), JobRunnerClientTimeout)
		_, err = r.masterClient.ReportUnitsCompletion(ctx, completionReq)
		cancel()

		if err != nil {
			retries = retries - 1
			if retries > 0 {
				log.Printf("got error, retrying after delay: %v", err)
				time.Sleep(JobRunnerRetryDelay)
			} else {
				return err
			}
		} else {
			return err
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
		Env: append(retrieveEnvVars(r.EnvVars), []string{
			fmt.Sprintf("PRIVET_RUNNER_ID=%s", r.runnerID),
		}...),
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
		Env: append(retrieveEnvVars(r.EnvVars), []string{
			fmt.Sprintf("PRIVET_RUNNER_ID=%s", r.runnerID),
		}...),
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
