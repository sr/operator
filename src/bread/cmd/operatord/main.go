package main

import (
	"database/sql"
	"errors"
	"flag"
	"fmt"
	"net"
	"net/http"
	"net/url"
	"os"
	"strings"
	"time"

	"bread"
	"bread/hal9000"
	"bread/pb"

	"github.com/sr/operator"
	"github.com/sr/operator/hipchat"
	"github.com/sr/operator/protolog"
	"golang.org/x/net/context"
	"google.golang.org/grpc"

	_ "github.com/go-sql-driver/mysql"
)

const grpcTimeout = 10 * time.Second

type config struct {
	afy   *bread.ArtifactoryConfig
	canoe *bread.CanoeConfig
	ecs   *bread.ECSConfig

	dev             bool
	devRoomID       int
	devHipchatToken string

	grpcAddr string
	halAddr  string
	httpAddr string
	timeout  time.Duration
	timezone string

	yubico *bread.YubicoConfig
	ldap   *bread.LDAPConfig

	databaseURL string
	prefix      string

	hipchatNamespace  string
	hipchatAddonURL   string
	hipchatWebhookURL string
}

func run(invoker operator.InvokerFunc) error {
	config := &config{
		afy:    &bread.ArtifactoryConfig{},
		canoe:  &bread.CanoeConfig{},
		ecs:    &bread.ECSConfig{},
		ldap:   &bread.LDAPConfig{},
		yubico: &bread.YubicoConfig{},
	}
	flags := flag.CommandLine
	flags.StringVar(&config.grpcAddr, "addr-grpc", ":9000", "Listen address of the gRPC server")
	flags.StringVar(&config.halAddr, "addr-hal9000", ":9001", "Address of the HAL9000 gRPC server")
	flags.StringVar(&config.httpAddr, "addr-http", ":8080", "Listen address of the HipChat addon and webhook HTTP server")
	flags.DurationVar(&config.timeout, "timeout", 10*time.Minute, "Timeout for gRPC requests")
	flags.StringVar(&config.timezone, "timezone", "America/New_York", "Display dates and times in this timezone")
	flags.BoolVar(&config.dev, "dev", false, "Enable development mode")
	flags.IntVar(&config.devRoomID, "dev-room-id", bread.TestingRoom, "Room ID where to send messages")
	flags.StringVar(&config.devHipchatToken, "dev-hipchat-token", "", "HipChat user token")
	flags.StringVar(&config.ldap.Addr, "ldap-addr", "localhost:389", "Address of the LDAP server used to authenticate and authorize commands")
	flags.StringVar(&config.ldap.Base, "ldap-base", bread.LDAPBase, "LDAP Base DN")
	flags.StringVar(&config.databaseURL, "database-url", "", "database/sql connection string to the database where OAuth credentials are stored")
	flags.StringVar(&config.prefix, "prefix", "!", "Prefix used to indicate commands in chat messages")
	flags.StringVar(&config.hipchatNamespace, "hipchat-namespace", "com.pardot.dev.operator", "Namespace used for all installations created via this server")
	flags.StringVar(&config.hipchatAddonURL, "hipchat-addon-url", "https://operator.dev.pardot.com/hipchat/addon", "HipChat addon installation endpoint URL")
	flags.StringVar(&config.hipchatWebhookURL, "hipchat-webhook-url", "https://operator.dev.pardot.com/hipchat/webhook", "HipChat webhook endpoint URL")
	flags.StringVar(&config.yubico.ID, "yubico-api-id", "", "Yubico API ID")
	flags.StringVar(&config.yubico.Key, "yubico-api-key", "", "Yubico API key")
	flags.StringVar(&config.afy.URL, "artifactory-url", "https://artifactory.dev.pardot.com/artifactory", "Artifactory URL")
	flags.StringVar(&config.afy.User, "artifactory-user", "", "Artifactory username")
	flags.StringVar(&config.afy.APIKey, "artifactory-api-key", "", "Artifactory API key")
	flags.StringVar(&config.afy.Repo, "artifactory-repo", "pd-docker", "Name of the Artifactory repository where deployable artifacts are stored")
	flags.StringVar(&config.canoe.URL, "canoe-url", "https://canoe.dev.pardot.com", "")
	flags.StringVar(&config.canoe.APIKey, "canoe-api-key", "", "Canoe API key")
	flags.StringVar(&config.ecs.AWSRegion, "ecs-aws-region", "us-east-1", "AWS Region")
	flags.DurationVar(&config.ecs.Timeout, "ecs-deploy-timeout", 5*time.Minute, "Time to wait for new ECS task definitions to come up")
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
		logger     protolog.Logger
		inst       operator.Instrumenter
		auth       operator.Authorizer
		sender     operator.Sender

		store    operatorhipchat.ClientCredentialsStore
		verifier bread.OTPVerifier
		db       *sql.DB
		hal      hal9000.RobotClient

		err error
	)
	httpServer = http.NewServeMux()
	logger = bread.NewLogger()
	inst = bread.NewInstrumenter(logger)
	if config.dev {
		auth = &noopAuthorizer{}
		if config.devRoomID == 0 {
			return errors.New("dev mode enabled but required flag missing: dev-room-id")
		}
		if v, ok := os.LookupEnv("HIPCHAT_TOKEN"); ok && config.devHipchatToken == "" {
			config.devHipchatToken = v
		}
		if config.devHipchatToken == "" {
			return errors.New("dev mode enabled but required flag missing: dev-hipchat-token")
		}
		cl, err := bread.NewHipchatClient(&operatorhipchat.ClientConfig{
			Hostname: bread.HipchatHost,
			Token:    config.devHipchatToken,
		})
		if err != nil {
			return err
		}
		sender = &devSender{client: cl, roomID: config.devRoomID}
	} else {
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
		if config.yubico.ID == "" {
			return fmt.Errorf("required flag missing: yubico-api-id")
		}
		if config.yubico.Key == "" {
			return fmt.Errorf("required flag missing: yubico-api-key")
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
		if verifier, err = bread.NewYubicoVerifier(config.yubico); err != nil {
			return err
		}
		if auth, err = bread.NewAuthorizer(config.ldap, verifier, bread.ACL); err != nil {
			return err
		}
	}
	tz, err := time.LoadLocation(config.timezone)
	if err != nil {
		return err
	}
	var grpcServer *grpc.Server
	if grpcServer, err = bread.NewServer(
		auth,
		inst,
		sender,
		bread.NewDeployServer(
			sender,
			bread.NewECSDeployer(config.ecs, config.afy, bread.ECSDeployTargets),
			bread.NewCanoeDeployer(config.canoe),
			tz,
		),
	); err != nil {
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
		httpServer.Handle("/replication/", bread.NewHandler(logger, bread.NewRepfixHandler(hal)))
	}
	if !config.dev {
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
			context.Background(),
			inst,
			operatorhipchat.NewRequestDecoder(store),
			sender,
			invoker,
			conn,
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
						Namespace:  config.hipchatNamespace,
						URL:        addonURL,
						Homepage:   bread.RepoURL,
						WebhookURL: webhookURL,
					},
				),
			),
		)
		httpServer.Handle("/hipchat/webhook", bread.NewHandler(logger, webhookHandler))
	}
	if config.httpAddr != "" {
		logger.Info(&breadpb.ServerStartupNotice{
			Protocol: "http",
			Address:  config.httpAddr,
			Hal9000:  config.halAddr,
		})
		go func() {
			errC <- http.ListenAndServe(config.httpAddr, httpServer)
		}()
	}
	return <-errC
}

func main() {
	if err := run(invoker); err != nil {
		fmt.Fprintf(os.Stderr, "operatord: %s\n", err)
		os.Exit(1)
	}
}

type noopAuthorizer struct{}

func (a *noopAuthorizer) Authorize(_ context.Context, _ *operator.Request) error {
	return nil
}

type devSender struct {
	client operatorhipchat.Client
	roomID int
}

func (r *devSender) Send(ctx context.Context, src *operator.Source, rep string, msg *operator.Message) error {
	notif := &operatorhipchat.RoomNotification{RoomID: int64(r.roomID)}
	if msg.HTML != "" {
		notif.MessageFormat = "html"
		notif.Message = msg.HTML
	} else {
		notif.MessageFormat = "text"
		notif.Message = msg.Text
	}
	if v, ok := msg.Options.(*operatorhipchat.MessageOptions); ok {
		notif.MessageOptions = v
	}
	return r.client.SendRoomNotification(ctx, notif)
}
