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

	"golang.org/x/net/context"
)

type JobMaster struct {
	privetDir       string
	exitCode        int
	unitsLock       sync.Mutex
	units           []string
	unitsInProgress map[string]bool
}

type JobMasterQueueStats struct {
	UnitsInQueue    int
	UnitsInProgress int
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
		Stdin:  nil,
		Stdout: buf,
	}

	if err := cmd.Run(); err != nil {
		return err
	}

	m.units = []string{}
	for _, unit := range strings.Split(buf.String(), "\n") {
		if len(unit) > 0 {
			m.units = append(m.units, unit)
		}
	}
	m.unitsInProgress = make(map[string]bool)

	return nil
}

func (m *JobMaster) PopUnits(ctx context.Context, req *PopUnitsRequest) (*PopUnitsResponse, error) {
	m.unitsLock.Lock()
	defer m.unitsLock.Unlock()

	maxUnits := int(req.UnitsRequested)
	if maxUnits > len(m.units) {
		maxUnits = len(m.units)
	}

	var units []string
	if len(m.units) > 0 {
		units, m.units = m.units[0:maxUnits], m.units[maxUnits:]
	} else {
		units = []string{}
	}

	for _, unit := range units {
		m.unitsInProgress[unit] = true
	}

	resp := &PopUnitsResponse{
		Units: units,
	}
	return resp, nil
}

func (m *JobMaster) ReportUnitsCompletion(ctx context.Context, req *ReportUnitsCompletionRequest) (*ReportUnitsCompletionResponse, error) {
	m.noticeExitCode(req.UnitResult.ExitCode)
	m.noticeExitCode(req.AdditionalResult.ExitCode)
	// TODO: Make this more of a queue. Or put the request on a channel?
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

func (m *JobMaster) QueueStats() JobMasterQueueStats {
	m.unitsLock.Lock()
	defer m.unitsLock.Unlock()

	return JobMasterQueueStats{
		UnitsInQueue:    len(m.units),
		UnitsInProgress: len(m.unitsInProgress),
	}
}
func (m *JobMaster) QueueLength() int {

	return len(m.units)
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
			delete(m.unitsInProgress, unit)
		}
		m.unitsLock.Unlock()
	}()

	env := []string{
		fmt.Sprintf("PRIVET_RUNNER_ID=%s", completionRequest.RunnerId),
		fmt.Sprintf("PRIVET_RESULT_ID=%s", completionRequest.ResultId),
		fmt.Sprintf("PRIVET_UNITS=%s", strings.Join(completionRequest.Units, "\n")),
	}

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
