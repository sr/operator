package main

import (
	"flag"
	"fmt"
	"net"
	"os"

	"github.com/sr/operator"
	"google.golang.org/grpc"
)

type noopAuthorizer struct{}

func (a noopAuthorizer) Authorize(*operator.Request) error {
	return nil
}

func run() error {
	config := &operator.Config{}
	flags := flag.CommandLine
	flags.StringVar(&config.Address, "listen-addr", operator.DefaultAddress, "Listen address of the operator server")
	logger := operator.NewLogger()
	instrumenter := operator.NewInstrumenter(logger)
	authorizer := noopAuthorizer{}
	interceptor := operator.NewInterceptor(instrumenter, authorizer)
	server := grpc.NewServer(grpc.UnaryInterceptor(interceptor))
	registerServices(server, logger, flags)
	if config.Address == "" {
		return fmt.Errorf("required -listen-addr flag is missing")
	}
	listener, err := net.Listen("tcp", config.Address)
	if err != nil {
		return err
	}
	logger.Info(&operator.ServerStartupNotice{Protocol: "tcp", Address: config.Address})
	return server.Serve(listener)
}

func main() {
	if err := run(); err != nil {
		fmt.Fprintf(os.Stderr, "operatord: %s\n", err)
		os.Exit(1)
	}
}
