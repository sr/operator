package main

import (
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"time"

	"git.dev.pardot.com/Pardot/bread/privet"
)

type stringListFlag []string

func (f *stringListFlag) String() string {
	return fmt.Sprintf("%v", *f)
}
func (f *stringListFlag) Set(value string) error {
	*f = append(*f, value)
	return nil
}

var (
	testManifest        string
	previousResultsDir  string
	numWorkers          int
	targetDuration      time.Duration
	defaultTestDuration time.Duration
	planFile            string
	commandPath         string
	worker              int
	parallelism         int
	envVars             stringListFlag
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
	flag.StringVar(&testManifest, "test-files-file", "", "A file containing a JSON array of test files to be run. The format is documented in the Privet examples directory.")
	flag.StringVar(&testManifest, "test-manifest", "", "A file containing a JSON array of test files to be run. The format is documented in the Privet examples directory.")
	flag.StringVar(&previousResultsDir, "previous-results-dir", "", "A directory containing JUnit-formatted XML files from a previous build. A SHASUMS file is also expected to exist containing fingerprints of the test files from this previous build. (optional, but helpful for plan)")
	flag.IntVar(&numWorkers, "num-workers", 0, "The number of workers to plan (required for plan)")
	flag.DurationVar(&targetDuration, "target-duration", 30*time.Second, "The target duration for one test batch. Should be balanced between too short (where startup/teardown time becomes an issue) and too long (where one worker might run much longer than the rest)")
	flag.DurationVar(&defaultTestDuration, "default-test-duration", 1*time.Second, "The default duration assumed for a test, if it cannot be found in the previous results")
	flag.StringVar(&planFile, "plan-file", "", "Path to the plan file (required for execute)")
	flag.StringVar(&commandPath, "command-path", "", "Command to execute for each test batch (required for execute)")
	flag.IntVar(&worker, "worker", -1, "Worker identifier (required for execute)")
	flag.IntVar(&parallelism, "parallelism", 1, "Number of independent processes to spawn to process this worker's queue")
	flag.Var(&envVars, "env", "Environment variable (foo=bar) to pass to the command (can be specified multiple times)")
	flag.Parse()

	switch flag.Arg(0) {
	case "plan":
		if err := doPlan(); err != nil {
			fmt.Fprintf(os.Stderr, "privet error: %v\n", err)
			os.Exit(1)
		}
	case "execute":
		success, err := doExecute()
		if err != nil {
			fmt.Fprintf(os.Stderr, "privet error: %v\n", err)
			fmt.Fprintf(os.Stderr, "The build failed due to an unexpected failure. Please open a ticket on https://jira.dev.pardot.com/browse/BREAD for the BREAD team to look into.")
			os.Exit(1)
		} else if !success {
			fmt.Fprintf(os.Stderr, "The build failed because at least one test job failed.")
			os.Exit(1)
		} else {
			os.Exit(0)
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

	if testManifest == "" {
		return errors.New("test-manifest is required")
	}
	testFiles, err := loadTestManifest(testManifest)
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
		return errors.New("num-workers is required")
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

func doExecute() (bool, error) {
	opts := &privet.PlanExecutionOpts{}

	if commandPath == "" {
		return false, errors.New("command-path is required")
	}
	opts.CommandPath = commandPath

	if planFile == "" {
		return false, errors.New("plan-file is required")
	}
	plan, err := loadPlan(planFile)
	if err != nil {
		return false, err
	}

	if worker < 0 {
		return false, errors.New("worker is required")
	}
	opts.Worker = worker
	opts.Parallelism = parallelism
	opts.Env = envVars

	return privet.ExecutePlan(plan, opts)
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

func loadTestManifest(file string) ([]*privet.TestFile, error) {
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

		results.Merge(fileResults)
		_ = f.Close()
	}

	shasumFile := filepath.Join(directory, "SHASUMS")
	if _, err := os.Stat(shasumFile); err == nil {
		f, err := os.Open(shasumFile)
		if err != nil {
			return nil, err
		}

		if err := privet.PopulateFingerprintsFromShasumsFile(results, f); err != nil {
			_ = f.Close()
			return nil, err
		}

		_ = f.Close()
	}

	return results, nil
}
