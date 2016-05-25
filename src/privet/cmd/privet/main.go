package main

import (
	"flag"
	"fmt"
	"log"
	"net"
	"os"
	"time"

	"privet"

	"google.golang.org/grpc"
)

var (
	bindAddress    string
	connectAddress string
	privetDir      string
	batchUnits     int
	timeout        int
)

func main() {
	flag.StringVar(&bindAddress, "bind", "", "The address:port to bind as a server")
	flag.StringVar(&connectAddress, "connect", "", "The address:port to connect as a client")
	flag.StringVar(&privetDir, "privet-dir", "./test/privet", "Path to where privet scripts reside")
	flag.IntVar(&batchUnits, "batch-units", 1, "Run multiple units at a time. Must be supported by the `run-units` script")
	flag.IntVar(&timeout, "timeout", 3600, "Number of seconds before the master will exit, assuming there is a hung test run")
	flag.Parse()

	if bindAddress != "" {
		listener, err := net.Listen("tcp", bindAddress)
		if err != nil {
			log.Fatalf("failed to bind: %v", err)
		}

		server := grpc.NewServer()
		master := privet.NewJobMaster(privetDir)

		if err = master.EnqueueUnits(); err != nil {
			log.Fatalf("failed to populate units: %v", err)
		}

		go func() {
			startTime := time.Now()
			timeoutDuration := time.Duration(timeout) * time.Second
			for {
				queueLength := master.QueueLength()
				if queueLength == 0 {
					os.Exit(master.ExitCode())
				}

				if time.Now().Sub(startTime) > timeoutDuration {
					log.Fatalf("timeout after %d seconds", timeout)
				} else {
					time.Sleep(1 * time.Second)
				}
			}
		}()

		privet.RegisterJobMasterServer(server, master)
		panic(server.Serve(listener))
	} else if connectAddress != "" {
		conn, err := grpc.Dial(connectAddress, grpc.WithInsecure())
		if err != nil {
			log.Fatalf("failed to connect: %v", err)
		}

		masterClient := privet.NewJobMasterClient(conn)
		jobRunner := privet.NewJobRunner(privetDir, masterClient)
		jobRunner.BatchUnits = int32(batchUnits)

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
