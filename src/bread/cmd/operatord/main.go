package main

import (
	"context"
	"database/sql"
	"flag"
	"fmt"
	"net"
	"net/http"
	"net/url"
	"os"
	"strings"
	"time"

	"bread"
	"bread/pb"

	"github.com/go-ldap/ldap"
	"github.com/sr/operator"
	"github.com/sr/operator/hipchat"
	"github.com/sr/operator/protolog"
	"google.golang.org/grpc"

	_ "github.com/go-sql-driver/mysql"
)

const ldapTimeout = 3 * time.Second

type config struct {
	grpcAddr string
	httpAddr string
	timeout  time.Duration

	ldapAddr string
	ldapBase string

	yubico *bread.YubicoConfig

	databaseURL string
	prefix      string

	hipchatNamespace  string
	hipchatAddonURL   string
	hipchatWebhookURL string

	deploy *bread.DeployConfig
}

func run(invoker operator.Invoker) error {
	config := &config{
		deploy: &bread.DeployConfig{Targets: bread.DeployTargets},
		yubico: &bread.YubicoConfig{},
	}
	flags := flag.CommandLine
	flags.StringVar(&config.grpcAddr, "addr-grpc", ":9000", "Listen address of the gRPC server")
	flags.StringVar(&config.httpAddr, "addr-http", ":8080", "Listen address of the HipChat addon and webhook HTTP server")
	flags.DurationVar(&config.timeout, "timeout", 5*time.Second, "TODO")
	flags.StringVar(&config.ldapAddr, "ldap-addr", "localhost:389", "Address of the LDAP server used to authenticate and authorize commands")
	flags.StringVar(&config.ldapBase, "ldap-base", bread.LDAPBase, "LDAP Base DN")
	flags.StringVar(&config.databaseURL, "database-url", "", "database/sql connection string to the database where OAuth credentials are stored")
	flags.StringVar(&config.prefix, "prefix", "!", "Prefix used to indicate commands in chat messages")
	flags.StringVar(&config.hipchatNamespace, "hipchat-namespace", "com.pardot.dev.operator", "Namespace used for all installations created via this server")
	flags.StringVar(&config.hipchatAddonURL, "hipchat-addon-url", "https://operator.dev.pardot.com/hipchat/addon", "HipChat addon installation endpoint URL")
	flags.StringVar(&config.hipchatWebhookURL, "hipchat-webhook-url", "https://operator.dev.pardot.com/hipchat/webhook", "HipChat webhook endpoint URL")
	flags.StringVar(&config.yubico.ID, "yubico-api-id", "", "Yubico API ID")
	flags.StringVar(&config.yubico.Key, "yubico-api-key", "", "Yubico API key")
	flags.StringVar(&config.deploy.ArtifactoryURL, "deploy-artifactory-url", "https://artifactory.dev.pardot.com/artifactory", "TODO")
	flags.StringVar(&config.deploy.ArtifactoryUsername, "deploy-artifactory-username", "", "")
	flags.StringVar(&config.deploy.ArtifactoryAPIKey, "deploy-artifactory-api-key", "", "TODO")
	flags.StringVar(&config.deploy.ArtifactoryRepo, "deploy-artifactory-repo", "pd-docker", "TODO")
	flags.StringVar(&config.deploy.AWSRegion, "deploy-aws-region", "us-east-1", "TODO")
	flags.StringVar(&config.deploy.CanoeECSService, "deploy-canoe-ecs-service", "", "TODO")
	flags.IntVar(&config.deploy.Timeout, "deploy-timeout", 120, "TODO")
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
	if config.yubico.ID == "" {
		return fmt.Errorf("required flag missing: yubico-api-id")
	}
	if config.yubico.Key == "" {
		return fmt.Errorf("required flag missing: yubico-api-key")
	}
	db, err := sql.Open("mysql", config.databaseURL)
	if err != nil {
		return err
	}
	if err := db.Ping(); err != nil {
		return err
	}
	var logger protolog.Logger
	logger = bread.NewLogger()
	var inst operator.Instrumenter
	inst = bread.NewInstrumenter(logger)
	var store operatorhipchat.ClientCredentialsStore
	store = operatorhipchat.NewSQLStore(db, bread.HipchatHost)
	var replier operator.Replier
	replier = operatorhipchat.NewReplier(store, bread.HipchatHost)
	var verifier bread.OTPVerifier
	if verifier, err = bread.NewYubicoVerifier(config.yubico); err != nil {
		return err
	}
	var lconn *ldap.Conn
	c, err := net.DialTimeout("tcp", config.ldapAddr, ldapTimeout)
	if err != nil {
		return err
	}
	lconn = ldap.NewConn(c, false)
	lconn.SetTimeout(ldapTimeout)
	lconn.Start()
	if err := lconn.Bind("", ""); err != nil {
		return err
	}
	var auth operator.Authorizer
	if auth, err = bread.NewAuthorizer(lconn, bread.LDAPBase, verifier); err != nil {
		return err
	}
	var grpcServer *grpc.Server
	grpcServer, err = bread.NewServer(
		auth,
		inst,
		replier,
		config.deploy,
	)
	if err != nil {
		return err
	}
	msg := &breadpb.ServerStartupNotice{Protocol: "grpc", Address: config.grpcAddr}
	for svc := range grpcServer.GetServiceInfo() {
		msg.Services = append(msg.Services, svc)
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
	conn, err := grpc.Dial(
		config.grpcAddr,
		grpc.WithInsecure(),
		grpc.WithUnaryInterceptor(bread.NewUnaryClientInterceptor(replier)),
	)
	if err != nil {
		return err
	}
	if webhookHandler, err = operator.NewHandler(
		context.Background(),
		config.timeout,
		inst,
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
		bread.NewHandler(logger, bread.NewPingHandler(db)),
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
		bread.NewHandler(
			logger,
			operatorhipchat.NewAddonHandler(
				store,
				&operatorhipchat.AddonConfig{
					Namespace:  config.hipchatNamespace,
					URL:        addonURL,
					Homepage:   bread.RepoURL,
					WebhookURL: webhookURL,
				},
			),
		),
	)
	httpServer.Handle("/hipchat/webhook", bread.NewHandler(logger, webhookHandler))
	logger.Info(&breadpb.ServerStartupNotice{Protocol: "http", Address: config.httpAddr})
	go func() {
		errC <- http.ListenAndServe(config.httpAddr, httpServer)
	}()
	return <-errC
}

func main() {
	if err := run(invoker); err != nil {
		fmt.Fprintf(os.Stderr, "operatord: %s\n", err)
		os.Exit(1)
	}
}
