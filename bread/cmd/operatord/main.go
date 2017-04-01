package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"net/http"
	"os"
	"strings"
	"time"

	"golang.org/x/oauth2/clientcredentials"
	"google.golang.org/grpc"

	"git.dev.pardot.com/Pardot/infrastructure/bread"
	"git.dev.pardot.com/Pardot/infrastructure/bread/api"
	"git.dev.pardot.com/Pardot/infrastructure/bread/generated/pb/hal9000"
	"git.dev.pardot.com/Pardot/infrastructure/bread/hipchat"
)

const grpcTimeout = 10 * time.Second

var (
	port               = flag.String("port", "", "Listen address of the HipChat addon and webhook HTTP server")
	halAddr            = flag.String("address-hal9000", "", "Address of the HAL9000 gRPC server")
	hipchatOAuthID     = flag.String("hipchat-oauth-id", "", "")
	hipchatOAuthSecret = flag.String("hipchat-oauth-secret", "", "")
)

func run() error {
	flags := flag.CommandLine
	// Allow setting flags via environment variables
	flags.VisitAll(func(f *flag.Flag) {
		k := strings.ToUpper(strings.Replace(f.Name, "-", "_", -1))
		if v := os.Getenv(k); v != "" {
			if err := f.Value.Set(v); err != nil {
				panic(err)
			}
		}
	})
	flag.Parse()
	var host, halPort string
	if v, ok := os.LookupEnv("HAL9000_PORT_9001_TCP_ADDR"); ok {
		host = v
	}
	if v, ok := os.LookupEnv("HAL9000_PORT_9001_TCP_PORT"); ok {
		halPort = v
	}
	if host != "" && halPort != "" {
		*halAddr = fmt.Sprintf("%s:%s", host, halPort)
	}
	if *port == "" {
		return fmt.Errorf("required flag missing: port")
	}

	logger := log.New(os.Stdout, "", log.LstdFlags)
	httpServer := http.NewServeMux()

	conn, err := grpc.Dial(*halAddr, grpc.WithBlock(), grpc.WithTimeout(grpcTimeout), grpc.WithInsecure())
	if err != nil {
		return err
	}

	hipchat, err := breadhipchat.NewClient(
		context.TODO(),
		&breadhipchat.ClientConfig{
			Hostname: bread.HipchatHost,
			Scopes:   breadhipchat.DefaultScopes,
			Credentials: &breadhipchat.ClientCredentials{
				ID:     *hipchatOAuthID,
				Secret: *hipchatOAuthSecret,
			},
		},
	)
	if err != nil {
		return err
	}

	robot := hal9000.NewRobotClient(conn)
	handler, err := breadapi.HipchatEventHandler(
		hipchat,
		&clientcredentials.Config{
			ClientID:     *hipchatOAuthID,
			ClientSecret: *hipchatOAuthSecret,
			TokenURL:     fmt.Sprintf("%s/v2/oauth/token", bread.HipchatHost),
			Scopes:       breadhipchat.DefaultScopes,
		},
		hal9000MessageHandler(logger, robot),
	)
	if err != nil {
		return err
	}

	httpServer.Handle("/hipchat/webhook", handler)
	httpServer.Handle("/replication/", bread.NewHandler(logger, newRepfixHandler(robot)))
	httpServer.Handle("/_ping", bread.NewHandler(logger, bread.NewPingHandler(nil)))

	return http.ListenAndServe(*port, httpServer)
}

func main() {
	if err := run(); err != nil {
		fmt.Fprintf(os.Stderr, "operatord: %s\n", err)
		os.Exit(1)
	}
}
