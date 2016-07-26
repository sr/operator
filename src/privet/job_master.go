package privet

import (
	"bytes"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"sync"
	"syscall"
	"time"

	"golang.org/x/net/context"
)

type JobMaster struct {
	EnvVars []string

	privetDir          string
	exitCode           int
	unitsLock          sync.RWMutex
	unitQueue          *UnitQueue
	unitDataInProgress map[string]bool
}

func NewJobMaster(privetDir string) *JobMaster {
	return &JobMaster{
		privetDir: privetDir,
	}
}

// EnqueueUnits runs the units command to populate the list of units to be run
func (m *JobMaster) EnqueueUnits() error {
	buf := new(bytes.Buffer)
	cmd := &exec.Cmd{
		Path:   filepath.Join(m.privetDir, "units"),
		Env:    retrieveEnvVars(m.EnvVars),
		Stdin:  nil,
		Stdout: buf,
	}

	if err := cmd.Run(); err != nil {
		return err
	}

	unitParser := NewUnitParser(buf)
	m.unitQueue = NewUnitQueue()
	for {
		unit, err := unitParser.Next()
		if err != nil {
			return err
		} else if unit != nil {
			m.unitQueue.Enqueue(unit)
		} else {
			break
		}
	}
	m.unitDataInProgress = make(map[string]bool)

	return nil
}

func (m *JobMaster) PopUnits(ctx context.Context, req *PopUnitsRequest) (*PopUnitsResponse, error) {
	m.unitsLock.Lock()
	defer m.unitsLock.Unlock()

	approximateDuration := time.Duration(req.ApproximateBatchDurationInSeconds) * time.Second
	units := m.unitQueue.Dequeue(approximateDuration)
	for _, unit := range units {
		m.unitDataInProgress[unit.Data] = true
	}

	resp := &PopUnitsResponse{
		Units: units,
	}
	return resp, nil
}

func (m *JobMaster) ReportUnitsCompletion(ctx context.Context, req *ReportUnitsCompletionRequest) (*ReportUnitsCompletionResponse, error) {
	m.noticeExitCode(req.UnitResult.ExitCode)
	m.noticeExitCode(req.AdditionalResult.ExitCode)
	// TODO: Make this more of a queue so it happens async. Or put the request on a channel?
	go m.invokeReceiveResults(req)

	return &ReportUnitsCompletionResponse{}, nil
}

// noticeExitCode notices an exit code that occurred during the execution of the
// tests. If at any point it sees a non-zero exit code, it remembers that so the
// entire process can exit non-zero later.
func (m *JobMaster) noticeExitCode(exitCode int32) {
	if m.exitCode == 0 && exitCode != 0 {
		m.exitCode = int(exitCode)
	}
}

func (m *JobMaster) IsWorkFullyCompleted() bool {
	m.unitsLock.RLock()
	defer m.unitsLock.RUnlock()

	return m.queueLength() == 0 && m.numUnitsInProgress() == 0
}

func (m *JobMaster) GetQueueStatistics(ctx context.Context, req *QueueStatisticsRequest) (*QueueStatisticsResponse, error) {
	m.unitsLock.RLock()
	defer m.unitsLock.RUnlock()

	return &QueueStatisticsResponse{
		UnitsInQueue:    int32(m.queueLength()),
		UnitsInProgress: int32(m.numUnitsInProgress()),
	}, nil
}

func (m *JobMaster) queueLength() int {
	return m.unitQueue.Size()
}

func (m *JobMaster) numUnitsInProgress() int {
	return len(m.unitDataInProgress)
}

func (m *JobMaster) ExitCode() int {
	return m.exitCode
}

func (m *JobMaster) removeTemporaryFile(name string) {
	if err := os.Remove(name); err != nil {
		log.Printf("unable to remove file '%s': %v", name, err)
	}
}

func (m *JobMaster) invokeReceiveResults(completionRequest *ReportUnitsCompletionRequest) {
	defer func() {
		m.unitsLock.Lock()
		for _, unit := range completionRequest.Units {
			delete(m.unitDataInProgress, unit.Data)
		}
		m.unitsLock.Unlock()
	}()

	unitsData := make([]string, 0, len(completionRequest.Units))
	for _, unit := range completionRequest.Units {
		unitsData = append(unitsData, unit.Data)
	}

	env := append(retrieveEnvVars(m.EnvVars), []string{
		fmt.Sprintf("PRIVET_RUNNER_ID=%s", completionRequest.RunnerId),
		fmt.Sprintf("PRIVET_RESULT_ID=%s", completionRequest.ResultId),
		fmt.Sprintf("PRIVET_UNITS=%s", strings.Join(unitsData, "\n")),
	}...)

	unitResultFile, err := ioutil.TempFile("", "privet")
	if err != nil {
		log.Printf("unable to create temporary file: %v", err)
		m.noticeExitCode(1)
		return
	}
	defer m.removeTemporaryFile(unitResultFile.Name())

	if _, err = unitResultFile.Write(completionRequest.UnitResult.Output); err != nil {
		log.Printf("unable to write to temporary file: %v", err)
		m.noticeExitCode(1)
		return
	}
	if err = unitResultFile.Close(); err != nil {
		log.Printf("unable to close temporary file: %v", err)
		m.noticeExitCode(1)
		return
	}
	env = append(env, fmt.Sprintf("PRIVET_UNIT_RESULT_CODE=%d", completionRequest.UnitResult.ExitCode))
	env = append(env, fmt.Sprintf("PRIVET_UNIT_RESULT_FILE=%s", unitResultFile.Name()))

	if completionRequest.AdditionalResultPresent {
		additionalResultFile, err := ioutil.TempFile("", "privet")
		if err != nil {
			log.Printf("unable to create temporary file: %v", err)
			m.noticeExitCode(1)
			return
		}
		defer m.removeTemporaryFile(additionalResultFile.Name())

		if _, err = additionalResultFile.Write(completionRequest.AdditionalResult.Output); err != nil {
			log.Printf("unable to write to temporary file: %v", err)
			m.noticeExitCode(1)
			return
		}
		if err = additionalResultFile.Close(); err != nil {
			log.Printf("unable to close temporary file: %v", err)
			m.noticeExitCode(1)
			return
		}
		env = append(env, fmt.Sprintf("PRIVET_ADDITIONAL_RESULT_CODE=%d", completionRequest.AdditionalResult.ExitCode))
		env = append(env, fmt.Sprintf("PRIVET_ADDITIONAL_RESULT_FILE=%s", additionalResultFile.Name()))
	}

	cmd := &exec.Cmd{
		Path:   filepath.Join(m.privetDir, "receive-results"),
		Env:    env,
		Stdin:  nil,
		Stdout: os.Stdout,
		Stderr: os.Stderr,
	}

	if err = cmd.Run(); err != nil {
		if exiterr, ok := err.(*exec.ExitError); ok {
			status := exiterr.Sys().(syscall.WaitStatus)

			log.Printf("receive-results process exited with code: %d", status.ExitStatus())
			m.noticeExitCode(int32(status.ExitStatus()))
		}
	}
}
