package main

import (
	"database/sql"
	"flag"
	"fmt"
	"log"
	"net"
	"net/http"
	"net/url"
	"os"
	"strings"
	"time"

	_ "github.com/go-sql-driver/mysql"
	"github.com/golang/protobuf/jsonpb"
	"github.com/sr/operator"
	operatorhipchat "github.com/sr/operator/hipchat"
	"google.golang.org/grpc"

	"git.dev.pardot.com/Pardot/infrastructure/bread"
	"git.dev.pardot.com/Pardot/infrastructure/bread/api"
	"git.dev.pardot.com/Pardot/infrastructure/bread/generated/pb/hal9000"
)

const (
	grpcTimeout = 10 * time.Second
)

type config struct {
	canoe *breadapi.CanoeConfig

	grpcAddr string
	halAddr  string
	httpAddr string
	timeout  time.Duration

	ldap *bread.LDAPConfig

	databaseURL string
	prefix      string

	hipchatNamespace  string
	hipchatAddonURL   string
	hipchatWebhookURL string
}

func run(invoker operator.InvokerFunc) error {
	config := &config{
		canoe: &breadapi.CanoeConfig{},
		ldap:  &bread.LDAPConfig{},
	}
	flags := flag.CommandLine
	flags.StringVar(&config.grpcAddr, "addr-grpc", ":9000", "Listen address of the gRPC server")
	flags.StringVar(&config.halAddr, "addr-hal9000", "", "Address of the HAL9000 gRPC server")
	flags.StringVar(&config.httpAddr, "addr-http", ":8080", "Listen address of the HipChat addon and webhook HTTP server")
	flags.DurationVar(&config.timeout, "timeout", 10*time.Minute, "Timeout for gRPC requests")
	flags.StringVar(&config.ldap.Addr, "ldap-addr", "localhost:389", "Address of the LDAP server used to authenticate and authorize commands")
	flags.StringVar(&config.ldap.Base, "ldap-base", bread.LDAPBase, "LDAP Base DN")
	flags.StringVar(&config.databaseURL, "database-url", "", "database/sql connection string to the database where OAuth credentials are stored")
	flags.StringVar(&config.prefix, "prefix", "!", "Prefix used to indicate commands in chat messages")
	flags.StringVar(&config.hipchatNamespace, "hipchat-namespace", "com.pardot.dev.operator", "Namespace used for all installations created via this server")
	flags.StringVar(&config.hipchatAddonURL, "hipchat-addon-url", "https://operator.dev.pardot.com/hipchat/addon", "HipChat addon installation endpoint URL")
	flags.StringVar(&config.hipchatWebhookURL, "hipchat-webhook-url", "https://operator.dev.pardot.com/hipchat/webhook", "HipChat webhook endpoint URL")
	flags.StringVar(&config.canoe.URL, "canoe-url", "https://canoe.dev.pardot.com", "")
	flags.StringVar(&config.canoe.APIKey, "canoe-api-key", "", "Canoe API key")
	// Allow setting flags via environment variables
	flags.VisitAll(func(f *flag.Flag) {
		k := strings.ToUpper(strings.Replace(f.Name, "-", "_", -1))
		if v := os.Getenv(k); v != "" {
			if err := f.Value.Set(v); err != nil {
				panic(err)
			}
		}
	})
	var host, port string
	if v, ok := os.LookupEnv("HAL9000_PORT_9001_TCP_ADDR"); ok {
		host = v
	}
	if v, ok := os.LookupEnv("HAL9000_PORT_9001_TCP_PORT"); ok {
		port = v
	}
	if host != "" && port != "" {
		config.halAddr = fmt.Sprintf("%s:%s", host, port)
	}
	if err := flags.Parse(os.Args[1:]); err != nil {
		return err
	}
	if config.grpcAddr == "" {
		return fmt.Errorf("required flag missing: addr-grpc")
	}
	var (
		httpServer *http.ServeMux
		logger     bread.Logger
		auth       bread.Authorizer
		sender     operator.Sender

		store    operatorhipchat.ClientCredentialsStore
		db       *sql.DB
		hal      hal9000.RobotClient
		canoeAPI bread.CanoeClient

		err error
	)
	httpServer = http.NewServeMux()
	logger = log.New(os.Stdout, "", log.LstdFlags)
	canoeURL, err := url.Parse(config.canoe.URL)
	if err != nil {
		return err
	}
	canoeAPI = bread.NewCanoeClient(canoeURL, config.canoe.APIKey)
	if config.httpAddr == "" {
		return fmt.Errorf("required flag missing: addr-http")
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
	if config.databaseURL == "" {
		return fmt.Errorf("required flag missing: database-url")
	}
	db, err = sql.Open("mysql", config.databaseURL)
	if err != nil {
		return err
	}
	if err := db.Ping(); err != nil {
		return err
	}
	httpServer.Handle("/_ping", bread.NewHandler(logger, bread.NewPingHandler(db)))
	store = operatorhipchat.NewSQLStore(db, bread.HipchatHost)
	sender = operatorhipchat.NewSender(store, bread.HipchatHost)
	if auth, err = bread.NewLDAPAuthorizer(config.ldap, canoeAPI, bread.ACL); err != nil {
		return err
	}

	var grpcServer *grpc.Server
	grpcServer = grpc.NewServer(grpc.UnaryInterceptor(bread.NewUnaryServerInterceptor(logger, &jsonpb.Marshaler{}, auth)))

	errC := make(chan error)
	grpcList, err := net.Listen("tcp", config.grpcAddr)
	if err != nil {
		return err
	}
	go func() {
		errC <- grpcServer.Serve(grpcList)
	}()
	var services []string
	for s := range grpcServer.GetServiceInfo() {
		services = append(services, s)
	}
	logger.Printf("grpc server listening on %s. registered services: %s", config.grpcAddr, strings.Join(services, " "))
	if config.halAddr != "" {
		if cc, err := grpc.Dial(
			config.halAddr,
			grpc.WithBlock(),
			grpc.WithTimeout(grpcTimeout),
			grpc.WithInsecure(),
		); err == nil {
			hal = hal9000.NewRobotClient(cc)
		} else {
			return err
		}
		httpServer.Handle("/replication/", bread.NewHandler(logger, newRepfixHandler(hal)))
	}
	var webhookHandler http.Handler
	conn, err := grpc.Dial(
		config.grpcAddr,
		grpc.WithBlock(),
		grpc.WithTimeout(grpcTimeout),
		grpc.WithInsecure(),
	)
	if err != nil {
		return err
	}
	const pkg = "bread"
	if webhookHandler, err = bread.NewHipchatHandler(
		logger,
		operatorhipchat.NewRequestDecoder(store),
		sender,
		conn,
		invoker,
		grpcServer.GetServiceInfo(),
		hal,
		config.timeout,
		config.prefix,
		pkg,
	); err != nil {
		return err
	}
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
		bread.NewHandler(
			logger,
			operatorhipchat.NewAddonHandler(
				store,
				&operatorhipchat.AddonConfig{
					Namespace:     config.hipchatNamespace,
					URL:           addonURL,
					Homepage:      bread.RepoURL,
					WebhookURL:    webhookURL,
					WebhookPrefix: config.prefix,
				},
			),
		),
	)
	httpServer.Handle("/hipchat/webhook", bread.NewHandler(logger, webhookHandler))
	if config.httpAddr != "" {
		logger.Printf("http server listening on %s", config.httpAddr)
		go func() {
			errC <- http.ListenAndServe(config.httpAddr, httpServer)
		}()
	}
	return <-errC
}

func main() {
	if err := run(nil); err != nil {
		fmt.Fprintf(os.Stderr, "operatord: %s\n", err)
		os.Exit(1)
	}
}
