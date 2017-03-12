// Command chatbotd is the HTTP server that receives and handles chat messages.
package main

import (
	"context"
	"errors"
	"flag"
	"fmt"
	"log"
	"net"
	"net/http"
	"net/url"
	"os"
	"os/signal"
	"strings"
	"time"

	heroku "github.com/cyberdelia/heroku-go/v3"
	"golang.org/x/oauth2/clientcredentials"
	"google.golang.org/grpc"

	"git.dev.pardot.com/Pardot/bread"
	"git.dev.pardot.com/Pardot/bread/hipchat"
)

var (
	port               = flag.String("port", "", "Listening port of the HTTP server. Defaults to $PORT.")
	hipchatOAuthID     = flag.String("hipchat-oauth-id", "", "")
	hipchatOAuthSecret = flag.String("hipchat-oauth-secret", "", "")
	herokuAPIUsername  = flag.String("heroku-api-username", "", "")
	herokuAPIPassword  = flag.String("heroku-api-password", "", "")

	hipchatAddonConfig = &breadhipchat.AddonConfig{}
)

func init() {
	flag.StringVar(&hipchatAddonConfig.Name, "hipchat-addon-name", "", "")
	flag.StringVar(&hipchatAddonConfig.Key, "hipchat-addon-key", "", "")
	flag.StringVar(&hipchatAddonConfig.Homepage, "hipchat-addon-homepage", "", "")
	flag.StringVar(&hipchatAddonConfig.URL, "hipchat-addon-url", "", "")
	flag.StringVar(&hipchatAddonConfig.WebhookURL, "hipchat-addon-webhook-url", "", "")
	flag.StringVar(&hipchatAddonConfig.AvatarURL, "hipchat-addon-avatar-url", "", "")
	flag.StringVar(&hipchatAddonConfig.HerokuApp, "hipchat-addon-heroku-app", "", "")
}

func main() {
	if err := run(); err != nil {
		fmt.Fprintf(os.Stderr, "chatbotd: %s\n", err)
		os.Exit(1)
	}
}

func run() error {
	flag.VisitAll(func(f *flag.Flag) {
		k := strings.ToUpper(strings.Replace(f.Name, "-", "_", -1))
		if v := os.Getenv(k); v != "" {
			if err := f.Value.Set(v); err != nil {
				panic(err)
			}
		}
	})
	flag.Parse()
	if *port == "" {
		return errors.New("required flag missing: port")
	}

	logger := log.New(os.Stderr, "chatbotd: ", 0)

	grpcListener, err := net.Listen("tcp", ":0")
	if err != nil {
		return err
	}
	grpcServer := grpc.NewServer()

	mux := http.NewServeMux()
	mux.HandleFunc("/_ping", bread.NewPingHandler(nil))

	// If we already have the Hipchat OAuth credentials, assume the addon has
	// been installed and setup to send messages to this server.
	if *hipchatOAuthID == "" && *hipchatOAuthSecret == "" {
		if *herokuAPIUsername == "" {
			return fmt.Errorf("required flag missing: heroku-api-username")
		}
		if *herokuAPIPassword == "" {
			return fmt.Errorf("required flag missing: heroku-api-password")
		}

		handler, err := breadhipchat.AddonHandler(
			heroku.NewService(&http.Client{
				Transport: &heroku.Transport{
					Username: *herokuAPIUsername,
					Password: *herokuAPIPassword,
				},
			}),
			hipchatAddonConfig,
		)
		if err != nil {
			return err
		}
		mux.HandleFunc("/hipchat/addon", handler)
	} else {
		webhookURL, err := url.Parse(hipchatAddonConfig.WebhookURL)
		if err != nil {
			return err
		}

		handler, err := breadhipchat.EventHandler(
			&clientcredentials.Config{
				ClientID:     *hipchatOAuthID,
				ClientSecret: *hipchatOAuthSecret,
				TokenURL:     fmt.Sprintf("%s/v2/oauth/token", bread.HipchatHost),
				Scopes:       breadhipchat.DefaultScopes,
			},
			breadhipchat.LogHandler(logger),
		)
		if err != nil {
			return err
		}
		mux.HandleFunc(webhookURL.Path, handler)
	}

	httpServer := &http.Server{
		Addr:     fmt.Sprintf(":%s", *port),
		ErrorLog: logger,
		Handler:  mux,
	}

	stopC := make(chan os.Signal)
	errC := make(chan error, 1)
	signal.Notify(stopC, os.Interrupt)

	go func() {
		errC <- grpcServer.Serve(grpcListener)
	}()

	go func() {
		errC <- httpServer.ListenAndServe()
	}()

	var services []string
	for s := range grpcServer.GetServiceInfo() {
		services = append(services, s)
	}
	logger.Printf("server listening on %s. registered gRPC services: %s", httpServer.Addr, strings.Join(services, " "))

	select {
	case <-stopC:
		ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
		defer cancel()
		if err := httpServer.Shutdown(ctx); err != nil {
			return err
		}
		// This blocks until all RPCs are finished.
		grpcServer.GracefulStop()
		return nil
	case err := <-errC:
		return err
	}
}
