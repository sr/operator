package main

import (
	"chatops"
	"flag"
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

var (
	listenAddr string
)

func main() {
	if err := run(); err != nil {
		fmt.Fprintf(os.Stderr, "%s: %s\n", program, err)
		os.Exit(1)
	}
}

func run() error {
	flag.StringVar(&listenAddr, "listen", "localhost:3000", "Listening address of the server")
	flag.Parse()
	server := grpc.NewServer()
	logger := operator.NewLogger()
	instrumenter := operator.NewInstrumenter(logger)
	authorizer := chatops.NewLDAPAuthorizer()
	registerServices(server, logger, instrumenter, authorizer)
	listener, err := net.Listen(protocol, listenAddr)
	if err != nil {
		return err
	}
	logger.Info(&operator.ServerStartupNotice{Address: listenAddr, Protocol: protocol})
	return server.Serve(listener)
}
