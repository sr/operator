package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"privet"
	"time"
)

var (
	testFilesFile       string
	previousResultsDir  string
	numWorkers          int
	targetDuration      time.Duration
	defaultTestDuration time.Duration
	planFile            string
	commandPath         string
	worker              int
)

func main() {
	flag.Usage = func() {
		fmt.Fprintf(os.Stderr, "Usage: %s [options] COMMAND\n", os.Args[0])
		fmt.Fprintf(os.Stderr, "\n")
		fmt.Fprintf(os.Stderr, "Commands:\n")
		fmt.Fprintf(os.Stderr, "  plan    Creates a plan\n")
		fmt.Fprintf(os.Stderr, "  execute Executes a plan\n")
		fmt.Fprintf(os.Stderr, "  help    Shows this help\n")
		fmt.Fprintf(os.Stderr, "\n")
		fmt.Fprintf(os.Stderr, "Options:\n")
		flag.PrintDefaults()
	}
	flag.StringVar(&testFilesFile, "test-files-file", "", "A file containing a JSON array of test files to be run. The format is documented in the Privet examples directory.")
	flag.StringVar(&previousResultsDir, "previous-results-dir", "", "A directory containing JUnit-formatted XML files from a previous build. A SHASUMS file is also expected to exist containing fingerprints of the test files from this previous build. (optional, but helpful for plan)")
	flag.IntVar(&numWorkers, "num-workers", 0, "The number of workers to plan (required for plan)")
	flag.DurationVar(&targetDuration, "target-duration", 30*time.Second, "The target duration for one test batch. Should be balanced between too short (where startup/teardown time becomes an issue) and too long (where one worker might run much longer than the rest)")
	flag.DurationVar(&defaultTestDuration, "default-test-duration", 1*time.Second, "The default duration assumed for a test, if it cannot be found in the previous results")
	flag.StringVar(&planFile, "plan-file", "", "Path to the plan file (required for execute)")
	flag.StringVar(&commandPath, "command-path", "", "Command to execute for each test batch (required for execute)")
	flag.IntVar(&worker, "worker", -1, "Worker identifier (required for execute)")
	flag.Parse()

	switch flag.Arg(0) {
	case "plan":
		if err := doPlan(); err != nil {
			fmt.Fprintf(os.Stderr, "error: %v\n", err)
			os.Exit(1)
		}
	case "execute":
		if err := doExecute(); err != nil {
			fmt.Fprintf(os.Stderr, "error: %v\n", err)
			os.Exit(1)
		}
	case "help":
		flag.Usage()
		os.Exit(0)
	default:
		flag.Usage()
		os.Exit(1)
	}
}

func doPlan() error {
	opts := &privet.PlanCreationOpts{}

	if testFilesFile == "" {
		return fmt.Errorf("test-files-file is required")
	}
	testFiles, err := loadTestFilesFile(testFilesFile)
	if err != nil {
		return err
	}
	opts.TestFiles = testFiles

	if previousResultsDir != "" {
		testRunResults, err := loadResultsDirectory(previousResultsDir)
		if err != nil {
			return err
		}
		opts.PreviousResults = testRunResults
	}

	if numWorkers <= 0 {
		return fmt.Errorf("num-workers is required")
	}
	opts.NumWorkers = numWorkers

	opts.TargetDuration = targetDuration
	opts.DefaultTestDuration = defaultTestDuration

	plan, err := privet.CreatePlan(opts)
	if err != nil {
		return err
	}

	encoder := json.NewEncoder(os.Stdout)
	if err := encoder.Encode(plan); err != nil {
		return err
	}

	return nil
}

func doExecute() error {
	opts := &privet.PlanExecutionOpts{}

	if commandPath == "" {
		return fmt.Errorf("command-path is required")
	}
	opts.CommandPath = commandPath

	if planFile == "" {
		return fmt.Errorf("plan-file is required")
	}
	plan, err := loadPlan(planFile)
	if err != nil {
		return err
	}
	fmt.Printf("%#v\n", plan)

	if worker < 0 {
		return fmt.Errorf("worker is required")
	}
	opts.Worker = worker

	success, err := privet.ExecutePlan(plan, opts)
	if err != nil {
		return err
	} else if !success {
		return fmt.Errorf("executing the test plan resulted in at least one test failure")
	}

	return nil
}

func loadPlan(file string) (*privet.Plan, error) {
	f, err := os.Open(file)
	if err != nil {
		return nil, err
	}
	defer func() { _ = f.Close() }()

	decoder := json.NewDecoder(f)

	var plan privet.Plan
	if err := decoder.Decode(&plan); err != nil {
		return nil, err
	}
	return &plan, nil
}

func loadTestFilesFile(file string) ([]*privet.TestFile, error) {
	f, err := os.Open(file)
	if err != nil {
		return nil, err
	}
	defer func() { _ = f.Close() }()

	decoder := json.NewDecoder(f)

	var testFiles []*privet.TestFile
	if err := decoder.Decode(&testFiles); err != nil {
		return nil, err
	}

	return testFiles, nil
}

func loadResultsDirectory(directory string) (privet.TestRunResults, error) {
	files, err := filepath.Glob(filepath.Join(directory, "*.xml"))
	if err != nil {
		return nil, err
	}

	results := privet.TestRunResults{}
	for _, file := range files {
		f, err := os.Open(file)
		if err != nil {
			return nil, err
		}

		fileResults, err := privet.ParseJunitResult(f)
		if err != nil {
			_ = f.Close()
			return nil, err
		}

		for k, v := range fileResults {
			results[k] = v
		}

		_ = f.Close()
	}

	return results, nil
}
