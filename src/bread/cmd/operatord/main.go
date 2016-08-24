package main

import (
	"bread"
	"database/sql"
	"flag"
	"fmt"
	"net"
	"net/http"
	"net/url"
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

	databaseURL string
	prefix      string

	hipchatNamespace  string
	hipchatAddonURL   string
	hipchatWebhookURL string
}

func run(builder operator.ServerBuilder, invoker operator.Invoker) error {
	config := &config{}
	flags := flag.CommandLine
	flags.StringVar(&config.grpcAddr, "addr-grpc", ":9000", "Listen address of the gRPC server")
	flags.StringVar(&config.httpAddr, "addr-http", ":8080", "Listen address of the HipChat addon and webhook HTTP server")
	flags.StringVar(&config.databaseURL, "database-url", "", "database/sql connection string to the database where OAuth credentials are stored")
	flags.StringVar(&config.prefix, "prefix", "!", "Prefix used to indicate commands in chat messages")
	flags.StringVar(&config.hipchatNamespace, "hipchat-namespace", "com.pardot.dev.operator", "Namespace used for all installations created via this server")
	flags.StringVar(&config.hipchatAddonURL, "hipchat-addon-url", "https://operator.dev.pardot.com/hipchat/addon", "HipChat addon installation endpoint URL")
	flags.StringVar(&config.hipchatWebhookURL, "hipchat-webhook-url", "https://operator.dev.pardot.com/hipchat/webhook", "HipChat webhook endpoint URL")
	// Allow setting flags via environment variables
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
	if config.grpcAddr == "" {
		return fmt.Errorf("required flag missing: addr-grpc")
	}
	if config.httpAddr == "" {
		return fmt.Errorf("required flag missing: addr-http")
	}
	if config.databaseURL == "" {
		return fmt.Errorf("required flag missing: database-url")
	}
	if config.prefix == "" {
		return fmt.Errorf("required flag missing: prefix")
	}
	if config.hipchatNamespace == "" {
		return fmt.Errorf("required flag missing: hipchat-namespace")
	}
	if config.hipchatAddonURL == "" {
		return fmt.Errorf("required flag missing: hipchat-addon-url")
	}
	if config.hipchatWebhookURL == "" {
		return fmt.Errorf("required flag missing: hipchat-webhook-url")
	}
	db, err := sql.Open("mysql", config.databaseURL)
	if err != nil {
		return err
	}
	if err := db.Ping(); err != nil {
		return err
	}
	var logger operator.Logger
	logger = bread.NewLogger()
	var store operatorhipchat.ClientCredentialsStore
	store = bread.NewHipchatCredsStore(db)
	var replier operator.Replier
	replier = operatorhipchat.NewReplier(store, bread.HipchatHost)
	var grpcServer *grpc.Server
	grpcServer = grpc.NewServer()
	msg := &operator.ServerStartupNotice{Protocol: "grpc", Address: config.grpcAddr}
	services, err := builder(replier, grpcServer, flags)
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
	errC := make(chan error)
	grpcList, err := net.Listen("tcp", config.grpcAddr)
	if err != nil {
		return err
	}
	go func() {
		errC <- grpcServer.Serve(grpcList)
	}()
	logger.Info(msg)
	var webhookHandler http.Handler
	conn, err := grpc.Dial(config.grpcAddr, grpc.WithInsecure())
	if err != nil {
		return err
	}
	if webhookHandler, err = operator.NewHandler(
		logger,
		operator.NewInstrumenter(logger),
		bread.NewLDAPAuthorizer(),
		operatorhipchat.NewRequestDecoder(store),
		config.prefix,
		conn,
		invoker,
	); err != nil {
		return err
	}
	httpServer := http.NewServeMux()
	httpServer.Handle(
		"/_ping",
		bread.NewHTTPLoggerHandler(
			logger,
			bread.NewPingHandler(db),
		),
	)
	addonURL, err := url.Parse(config.hipchatAddonURL)
	if err != nil {
		return err
	}
	webhookURL, err := url.Parse(config.hipchatWebhookURL)
	if err != nil {
		return err
	}
	httpServer.Handle(
		"/hipchat/addon",
		bread.NewHTTPLoggerHandler(
			logger,
			bread.NewHipchatAddonHandler(
				config.prefix,
				config.hipchatNamespace,
				addonURL,
				webhookURL,
				store,
			),
		),
	)
	httpServer.Handle(
		"/hipchat/webhook",
		bread.NewHTTPLoggerHandler(
			logger,
			webhookHandler,
		),
	)
	logger.Info(&operator.ServerStartupNotice{Protocol: "http", Address: config.httpAddr})
	go func() {
		errC <- http.ListenAndServe(config.httpAddr, httpServer)
	}()
	return <-errC
}

func main() {
	if err := run(buildOperatorServer, invoker); err != nil {
		fmt.Fprintf(os.Stderr, "operatord: %s\n", err)
		os.Exit(1)
	}
}
