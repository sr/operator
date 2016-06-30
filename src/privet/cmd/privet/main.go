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
)

var (
	bindAddress                       string
	connectAddress                    string
	privetDir                         string
	approximateBatchDurationInSeconds float64
	envVars                           string
	timeout                           int
)

func main() {
	flag.StringVar(&bindAddress, "bind", "", "The address:port to bind as a server")
	flag.StringVar(&connectAddress, "connect", "", "The address:port to connect as a client")
	flag.StringVar(&privetDir, "privet-dir", "./test/privet", "Path to where privet scripts reside")
	flag.Float64Var(&approximateBatchDurationInSeconds, "approximate-batch-duration", 0, "Run multiple units at a time, totaling approximately this number of seconds. If zero (default), only one test will be run per invocation of runner-run-units.")
	flag.StringVar(&envVars, "env-vars", "", "Space-separated list of environment variables that will be forwarded on to any child processes run in the privet-dir")
	flag.IntVar(&timeout, "timeout", 3600, "Number of seconds before the process will exit, assuming there is a hung test run")
	flag.Parse()

	envVarsList := strings.Split(envVars, " ")
	if bindAddress != "" {
		go exitAfterTimeout(time.Duration(timeout) * time.Second)

		listener, err := net.Listen("tcp", bindAddress)
		if err != nil {
			log.Fatalf("failed to bind: %v", err)
		}

		server := grpc.NewServer()
		master := privet.NewJobMaster(privetDir)
		master.EnvVars = envVarsList

		if err = master.EnqueueUnits(); err != nil {
			log.Fatalf("failed to populate units: %v", err)
		}

		go func(master *privet.JobMaster) {
			for {
				queueStats := master.QueueStats()
				if queueStats.UnitsInQueue == 0 && queueStats.UnitsInProgress == 0 {
					os.Exit(master.ExitCode())
				}
				time.Sleep(1 * time.Second)
			}
		}(master)

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

		if err = jobRunner.RunStartupHook(); err != nil {
			log.Fatalf("error running startup hook: %v", err)
		}

		for {
			done, err := jobRunner.PopAndRunUnits()

			if err != nil {
				log.Fatalf("error running units: %v", err)
			} else if done {
				break
			}
		}

		if err = jobRunner.RunCleanupHook(); err != nil {
			log.Fatalf("error running startup hook: %v", err)
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
