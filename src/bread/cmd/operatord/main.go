package main

import (
	"bread"
	"flag"
	"fmt"
	"net"
	"net/http"
	"os"

	"github.com/sr/operator"
	"github.com/sr/operator/hipchat"
)

func run(builder operator.ServerBuilder, dispatcher operator.RequestDispatcher) error {
	config := &operator.Config{}
	flags := flag.CommandLine
	flags.StringVar(&config.Address, "listen-addr", operator.DefaultAddress, "Listen address of the operator server")
	logger := operator.NewLogger()
	server := bread.NewOperatorServer()
	recv := http.NewServeMux()
	recv.Handle(
		"/hipchat",
		operator.NewHandler(
			logger,
			operator.NewInstrumenter(logger),
			bread.NewLDAPAuthorizer(),
			operatorhipchat.NewRequestDecoder(),
			dispatcher,
		),
	)
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
	errC := make(chan error)
	listener, err := net.Listen("tcp", config.Address)
	if err != nil {
		return err
	}
	logger.Info(msg)
	go func() {
		errC <- server.Serve(listener)
	}()
	go func() {
		errC <- http.ListenAndServe(":8000", recv)
	}()
	return <-errC
}

func main() {
	if err := run(buildOperatorServer, requestDispatcher); err != nil {
		fmt.Fprintf(os.Stderr, "operatord: %s\n", err)
		os.Exit(1)
	}
}
