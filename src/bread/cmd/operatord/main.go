package main

import (
	"bread"
	"flag"
	"fmt"
	"net"
	"os"

	"github.com/sr/operator"

	_ "github.com/go-sql-driver/mysql"
)

func run(builder operator.ServerBuilder) error {
	config := &operator.Config{}
	flags := flag.CommandLine
	flags.StringVar(&config.Address, "listen-addr", operator.DefaultAddress, "Listen address of the operator server")
	logger := operator.NewLogger()
	server := bread.NewOperatorServer(logger)
	msg := &operator.ServerStartupNotice{Protocol: "tcp"}
	services, err := builder(server, flags)
	if err != nil {
		return err
	}
	for svc, err := range services {
		if err != nil {
			logger.Error(&operator.ServiceStartupError{
				Service: &operator.Service{Name: svc},
				Message: err.Error(),
			})
		} else {
			msg.Services = append(msg.Services, &operator.Service{Name: svc})
		}
	}
	msg.Address = config.Address
	if config.Address == "" {
		return fmt.Errorf("required -listen-addr flag is missing")
	}
	listener, err := net.Listen("tcp", config.Address)
	if err != nil {
		return err
	}
	logger.Info(msg)
	return server.Serve(listener)
}

func main() {
	if err := run(buildOperatorServer); err != nil {
		fmt.Fprintf(os.Stderr, "operatord: %s\n", err)
		os.Exit(1)
	}
}
