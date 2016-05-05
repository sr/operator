package main

import (
	"chatops"
	"fmt"
	"net"
	"os"

	"github.com/sr/operator"
	"google.golang.org/grpc"
)

const (
	program  = "operatord"
	protocol = "tcp"
)

func main() {
	if err := run(); err != nil {
		fmt.Fprintf(os.Stderr, "%s: %s\n", program, err)
		os.Exit(1)
	}
}

func run() error {
	config, err := operator.NewConfigFromEnv()
	if err != nil {
		return err
	}
	server := grpc.NewServer()
	logger := operator.NewLogger()
	instrumenter := operator.NewInstrumenter(logger)
	authorizer := chatops.NewLDAPAuthorizer()
	registerServices(server, logger, instrumenter, authorizer)
	listener, err := net.Listen(protocol, config.Address)
	if err != nil {
		return err
	}
	logger.Info(&operator.ServerStartupNotice{Address: config.Address, Protocol: protocol})
	return server.Serve(listener)
}
