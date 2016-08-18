package main

import (
	"bread"
	"database/sql"
	"flag"
	"fmt"
	"net"
	"net/http"
	"os"
	"strings"

	"google.golang.org/grpc"

	"github.com/sr/operator"
	"github.com/sr/operator/hipchat"

	_ "github.com/go-sql-driver/mysql"
)

type config struct {
	grpcAddr string
	httpAddr string
	prefix   string

	databaseURL string

	hipchatAddonSetup bool
	hipchatAddonID    string
	hipchatAddonURL   string
	hipchatWebhookURL string

	webhookEnabled bool
}

func run(builder operator.ServerBuilder, invoker operator.Invoker) error {
	config := &config{}
	flags := flag.CommandLine
	flags.StringVar(&config.grpcAddr, "grpc-addr", ":9000", "Listen address of the operator gRPC server")
	flags.StringVar(&config.httpAddr, "http-addr", ":8080", "Listen address of the HTTP webhook server. Optional.")
	flags.StringVar(&config.prefix, "prefix", "!", "The prefix used to denote a command invocation in chat messages")
	flags.StringVar(&config.databaseURL, "database-url", "", "")
	flags.BoolVar(&config.hipchatAddonSetup, "hipchat-addon-setup", false, "")
	flags.StringVar(&config.hipchatAddonID, "hipchat-addon-id", "", "")
	flags.StringVar(&config.hipchatAddonURL, "hipchat-addon-url", "", "")
	flags.StringVar(&config.hipchatWebhookURL, "hipchat-webhook-url", "", "")
	flags.BoolVar(&config.webhookEnabled, "enable-webhook", true, "")
	flags.VisitAll(func(f *flag.Flag) {
		k := strings.ToUpper(strings.Replace(f.Name, "-", "_", -1))
		if v := os.Getenv(k); v != "" {
			if err := f.Value.Set(v); err != nil {
				panic(err)
			}
		}
	})
	if err := flags.Parse(os.Args[1:]); err != nil {
		return err
	}
	if config.databaseURL == "" {
		return fmt.Errorf("required flag missing: database-url")
	}
	if config.httpAddr == "" {
		return fmt.Errorf("required flag missing: http-addr")
	}
	if config.prefix == "" {
		return fmt.Errorf("required flag missing: prefix")
	}
	logger := bread.NewLogger()
	errC := make(chan error)
	db, err := sql.Open("mysql", config.databaseURL)
	if err != nil {
		return err
	}
	if err := db.Ping(); err != nil {
		return err
	}
	mux := http.NewServeMux()
	mux.Handle("/_ping", bread.NewHTTPLoggerHandler(logger, bread.NewPingHandler(db)))
	store := bread.NewHipchatOAuthClientStore(db)
	if config.hipchatAddonSetup {
		if config.hipchatAddonURL == "" {
			return fmt.Errorf("required flag missing: hipchat-addon-url")
		}
		if config.hipchatWebhookURL == "" {
			return fmt.Errorf("required flag missing: hipchat-webhook-url")
		}
		if config.hipchatAddonID == "" {
			return fmt.Errorf("required flag missing: hipchat-addon-id")
		}
		h, err := bread.NewHipchatAddonHandler(
			config.hipchatAddonID,
			config.hipchatAddonURL,
			config.hipchatWebhookURL,
			store,
			config.prefix,
		)
		if err != nil {
			return err
		}
		mux.Handle("/hipchat/addon", bread.NewHTTPLoggerHandler(logger, h))
	} else {
		if config.grpcAddr != "" {
			if config.hipchatAddonID == "" {
				return fmt.Errorf("required flag missing: hipchat-addon-id")
			}
			c, err := store.GetByAddonID(config.hipchatAddonID)
			if err != nil {
				return err
			}
			chat, err := bread.NewHipchatClient(&bread.HipchatConfig{OAuthClient: c})
			if err != nil {
				return err
			}
			server := grpc.NewServer()
			msg := &operator.ServerStartupNotice{Protocol: "grpc", Address: config.grpcAddr}
			services, err := builder(chat, server, flags)
			if err != nil {
				return err
			}
			for svc, err := range services {
				if err != nil {
					logger.Error(
						&operator.ServiceStartupError{
							Service: &operator.Service{Name: svc},
							Message: err.Error(),
						},
					)
				} else {
					msg.Services = append(msg.Services, &operator.Service{Name: svc})
				}
			}
			listener, err := net.Listen("tcp", config.grpcAddr)
			if err != nil {
				return err
			}
			go func() {
				errC <- server.Serve(listener)
			}()
			logger.Info(msg)
		}
		if config.webhookEnabled {
			if config.grpcAddr == "" {
				return fmt.Errorf("required flag missing: grpc-addr")
			}
			if config.httpAddr == "" {
				return fmt.Errorf("required flag missing: http-addr")
			}
			conn, err := grpc.Dial(config.grpcAddr, grpc.WithInsecure())
			if err != nil {
				return err
			}
			handler, err := operator.NewHandler(
				logger,
				operator.NewInstrumenter(logger),
				bread.NewLDAPAuthorizer(),
				operatorhipchat.NewRequestDecoder(store),
				config.prefix,
				conn,
				invoker,
			)
			if err != nil {
				return err
			}
			mux.Handle("/hipchat/webhook", bread.NewHTTPLoggerHandler(logger, handler))
			logger.Info(&operator.ServerStartupNotice{Protocol: "http", Address: config.httpAddr})
		}
	}
	go func() {
		errC <- http.ListenAndServe(config.httpAddr, mux)
	}()
	return <-errC
}

func main() {
	if err := run(buildOperatorServer, invoker); err != nil {
		fmt.Fprintf(os.Stderr, "operatord: %s\n", err)
		os.Exit(1)
	}
}
