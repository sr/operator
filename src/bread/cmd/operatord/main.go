package main

import (
	"bread"
	"flag"
	"fmt"
	"net"
	"net/http"
	"os"

	"google.golang.org/grpc"

	"github.com/sr/operator"
	"github.com/sr/operator/hipchat"
)

var (
	grpcAddr string
	httpAddr string
	prefix   string

	hipchatAddonID    string
	hipchatAddonURL   string
	hipchatWebhookURL string
)

func run(builder operator.ServerBuilder, invoker operator.Invoker) error {
	flags := flag.CommandLine
	flags.StringVar(&grpcAddr, "grpc-addr", ":9000", "Listen address of the operator gRPC server")
	flags.StringVar(&httpAddr, "http-addr", ":8080", "Listen address of the HTTP webhook server. Optional.")
	flags.StringVar(&prefix, "prefix", "!", "The prefix used to denote a command invocation in chat messages")
	flags.StringVar(&hipchatAddonID, "hipchat-addon-id", "", "")
	flags.StringVar(&hipchatAddonURL, "hipchat-addon-url", "", "")
	flags.StringVar(&hipchatWebhookURL, "hipchat-webhook-url", "", "")
	logger := operator.NewLogger()
	server := bread.NewOperatorServer()
	errC := make(chan error)
	msg := &operator.ServerStartupNotice{Protocol: "grpc"}
	services, err := builder(server, flags)
	if err != nil {
		return err
	}
	if grpcAddr == "" {
		return fmt.Errorf("required flag missing: grpc-addr")
	}
	msg.Address = grpcAddr
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
	listener, err := net.Listen("tcp", grpcAddr)
	if err != nil {
		return err
	}
	go func() {
		errC <- server.Serve(listener)
	}()
	logger.Info(msg)
	if httpAddr != "" {
		conn, err := grpc.Dial(grpcAddr, grpc.WithInsecure())
		if err != nil {
			return err
		}
		handler, err := operator.NewHandler(
			logger,
			operator.NewInstrumenter(logger),
			bread.NewLDAPAuthorizer(),
			operatorhipchat.NewRequestDecoder(),
			prefix,
			conn,
			invoker,
		)
		if err != nil {
			return err
		}
		mux := http.NewServeMux()
		mux.HandleFunc("/_ping", bread.PingHandler)
		mux.Handle("/hipchat/webhook", handler)
		if hipchatAddonURL != "" {
			if hipchatWebhookURL == "" {
				return fmt.Errorf("require flag missing: hipchat-webhook-url")
			}
			if hipchatAddonID == "" {
				return fmt.Errorf("require flag missing: hipchat-addon-id")
			}
			h, err := bread.NewHipchatAddonHandler(
				hipchatAddonID,
				hipchatAddonURL,
				hipchatWebhookURL,
				prefix,
			)
			if err != nil {
				return err
			}
			mux.Handle("/hipchat/addon", h)
		}
		go func() {
			errC <- http.ListenAndServe(httpAddr, mux)
		}()
		logger.Info(&operator.ServerStartupNotice{Protocol: "http", Address: httpAddr})
	}
	return <-errC
}

func main() {
	if err := run(buildOperatorServer, invoker); err != nil {
		fmt.Fprintf(os.Stderr, "operatord: %s\n", err)
		os.Exit(1)
	}
}
