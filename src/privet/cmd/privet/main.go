package main

import (
	"flag"
	"fmt"
	"log"
	"net"
	"os"
	"strings"
	"time"

	"privet"

	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
)

var (
	bindAddress                       string
	connectAddress                    string
	privetDir                         string
	approximateBatchDurationInSeconds float64
	envVars                           string
	timeout                           int
	overlookStartupHookFailure        bool
)

func main() {
	flag.StringVar(&bindAddress, "bind", "", "The address:port to bind as a server")
	flag.StringVar(&connectAddress, "connect", "", "The address:port to connect as a client")
	flag.StringVar(&privetDir, "privet-dir", "./test/privet", "Path to where privet scripts reside")
	flag.Float64Var(&approximateBatchDurationInSeconds, "approximate-batch-duration", 0, "Run multiple units at a time, totaling approximately this number of seconds. If zero (default), only one test will be run per invocation of runner-run-units.")
	flag.StringVar(&envVars, "env-vars", "", "Space-separated list of environment variables that will be forwarded on to any child processes run in the privet-dir")
	flag.IntVar(&timeout, "timeout", 3600, "Number of seconds before the process will exit, assuming there is a hung test run")
	flag.BoolVar(&overlookStartupHookFailure, "overlook-startup-hook-failure", false, "If true, Privet will exit with status 0 if a startup hook fails. No tests will be run, but the failure will be essentially ignored")
	flag.Parse()

	envVarsList := strings.Split(envVars, " ")
	if bindAddress != "" {
		go exitAfterTimeout(time.Duration(timeout) * time.Second)

		server := grpc.NewServer()
		master := privet.NewJobMaster(privetDir)
		master.EnvVars = envVarsList
		if err := master.EnqueueUnits(); err != nil {
			log.Fatalf("failed to populate units: %v", err)
		}

		go func(master *privet.JobMaster) {
			for {
				if master.IsWorkFullyCompleted() {
					os.Exit(master.ExitCode())
				}
				time.Sleep(1 * time.Second)
			}
		}(master)

		listener, err := net.Listen("tcp", bindAddress)
		if err != nil {
			log.Fatalf("failed to bind: %v", err)
		}

		privet.RegisterJobMasterServer(server, master)
		panic(server.Serve(listener))
	} else if connectAddress != "" {
		go exitAfterTimeout(time.Duration(timeout) * time.Second)

		conn, err := grpc.Dial(connectAddress, grpc.WithInsecure())
		if err != nil {
			log.Fatalf("failed to connect: %v", err)
		}

		masterClient := privet.NewJobMasterClient(conn)
		jobRunner := privet.NewJobRunner(privetDir, masterClient)
		jobRunner.EnvVars = envVarsList
		jobRunner.ApproximateBatchDurationInSeconds = approximateBatchDurationInSeconds

		startupErrCh := make(chan error)
		go func() {
			startupErrCh <- jobRunner.RunStartupHook()
		}()
		queueEmptyCh := make(chan bool)
		go jobRunner.NotifyQueueEmpty(queueEmptyCh)

		select {
		case err = <-startupErrCh:
			if err != nil {
				log.Printf("error running startup hook: %v", err)
				if overlookStartupHookFailure {
					os.Exit(0)
				} else {
					os.Exit(1)
				}
			}
		case <-queueEmptyCh:
			log.Printf("queue became empty, exiting")
			os.Exit(0)
		}

		firstIteration := true
		success := true
		for {
			units, err := jobRunner.PopUnits()
			if err != nil {
				// If this is the first iteration and the exit code is a
				// DeadlineExceeded, it's likely that an anomalous startup hook run took
				// so long that other Privet workers have completed all of the work and
				// the Privet master has shut down. We allow this as a special case.
				if !firstIteration || grpc.Code(err) != codes.DeadlineExceeded {
					log.Printf("error fetching units: %v", err)
					success = false
				}
				break
			} else if len(units) <= 0 {
				break
			}

			err = jobRunner.RunUnits(units)
			if err != nil {
				log.Printf("error running units: %v", err)
				success = false
				break
			}

			firstIteration = false
		}

		if err = jobRunner.RunCleanupHook(); err != nil {
			log.Fatalf("error running cleanup hook: %v", err)
		}

		if success {
			os.Exit(0)
		} else {
			os.Exit(1)
		}
	} else {
		fmt.Fprintf(os.Stderr, "-bind or -connect must be specified\n")
		os.Exit(1)
	}
}

func exitAfterTimeout(timeout time.Duration) {
	startTime := time.Now()
	for {
		if time.Now().Sub(startTime) > timeout {
			log.Fatalf("timeout after %d", timeout)
		} else {
			time.Sleep(1 * time.Second)
		}
	}
}
