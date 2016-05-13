package main

import (
	"flag"
	"fmt"
	"net"
	"os"

	"github.com/sr/operator"
	"google.golang.org/grpc"
)

const defaultListenAddr = "localhost:3000"

type noopAuthorizer struct{}

func (a noopAuthorizer) Authorize(*operator.Source) error {
	return nil
}

func run() error {
	config := &operator.Config{}
	flags := flag.CommandLine
	flags.StringVar(&config.Address, "listen-addr", defaultListenAddr, "Listen address of the operator server")
	server := grpc.NewServer()
	logger := operator.NewLogger()
	instrumenter := operator.NewInstrumenter(logger)
	registerServices(server, logger, instrumenter, noopAuthorizer{}, flags)
	if config.Address == "" {
		return fmt.Errorf("required -listen-addr flag is missing.")
	}
	listener, err := net.Listen("tcp", config.Address)
	if err != nil {
		return err
	}
	return server.Serve(listener)
}

func main() {
	if err := run(); err != nil {
		fmt.Fprintf(os.Stderr, "operatord: %s\n", err)
		os.Exit(1)
	}
}
