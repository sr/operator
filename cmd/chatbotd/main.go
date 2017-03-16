// Command chatbotd is the HTTP server that receives and handles chat messages.
package main

import (
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
	"sync"
	"time"

	heroku "github.com/cyberdelia/heroku-go/v3"
	"github.com/sr/operator/hipchat"
	"golang.org/x/net/context"
	"golang.org/x/oauth2/clientcredentials"
	"google.golang.org/grpc"

	"git.dev.pardot.com/Pardot/bread"
	"git.dev.pardot.com/Pardot/bread/hipchat"
)

const grpcDialTimeout = 2 * time.Second

var (
	port               = flag.String("port", "", "Listening port of the HTTP server. Defaults to $PORT.")
	timeout            = flag.Duration("command-timeout", 10*time.Minute, "")
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

	client, err := operatorhipchat.NewClient(
		context.TODO(),
		&operatorhipchat.ClientConfig{
			Hostname: bread.HipchatHost,
			Scopes:   breadhipchat.DefaultScopes,
			Credentials: &operatorhipchat.ClientCredentials{
				ID:     *hipchatOAuthID,
				Secret: *hipchatOAuthSecret,
			},
		},
	)
	if err != nil {
		return err
	}

	errC := make(chan error, 1)

	// Start the gRPC server and establish a client connection to it.
	grpcListener, err := net.Listen("tcp", ":0")
	if err != nil {
		return err
	}
	grpcServer := grpc.NewServer()
	go func() {
		errC <- grpcServer.Serve(grpcListener)
	}()
	conn, err := grpc.Dial(
		grpcListener.Addr().String(),
		grpc.WithBlock(),
		grpc.WithTimeout(grpcDialTimeout),
		grpc.WithInsecure(),
	)
	if err != nil {
		return err
	}

	// Channel used to by the event HTTP server to send chat commands to the workers.
	chatCommands := make(chan *bread.ChatCommand, 100)

	// All chat messages are processed through these functions
	messageHandlers := []bread.ChatMessageHandler{
		bread.LogHandler(logger),
		bread.ChatCommandHandler(chatCommands),
	}

	mux := http.NewServeMux()
	mux.HandleFunc("/_ping", bread.NewPingHandler(nil))

	// Either mount the Hipchat addon server or event servers, depending on
	// whether OAuth client credentials are available or not.
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
			func(msg *bread.ChatMessage) error {
				var fail bool
				for _, handler := range messageHandlers {
					if err := handler(msg); err != nil {
						fail = true
						logger.Printf("error handling message: %s", err)
					}
				}
				if fail {
					return errors.New("one of the handler failed. check the logs for details")
				}
				return nil
			},
		)
		if err != nil {
			return err
		}
		mux.HandleFunc(webhookURL.Path, handler)
	}

	// Start chat command workers.
	var wg sync.WaitGroup
	for i := 0; i < 10; i++ {
		wg.Add(1)
		go func() {
			for cmd := range chatCommands {
				if err := bread.HandleChatRPCCommand(client, Invoker, *timeout, conn, cmd); err != nil {
					logger.Printf("command handler error: %s", err)
				}
			}
			wg.Done()
		}()
	}

	// Start the HTTP server.
	httpServer := &http.Server{
		Addr:     fmt.Sprintf(":%s", *port),
		ErrorLog: logger,
		Handler:  mux,
	}
	go func() {
		errC <- httpServer.ListenAndServe()
	}()

	var services []string
	for s := range grpcServer.GetServiceInfo() {
		services = append(services, s)
	}
	logger.Printf("server listening on %s. registered gRPC services: %s", httpServer.Addr, strings.Join(services, " "))

	// Gracefully shutdown the HTTP and gRPC servers, and chat command handler
	// goroutines on SIGINT.
	stopC := make(chan os.Signal)
	signal.Notify(stopC, os.Interrupt)

	select {
	case <-stopC:
		ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
		defer cancel()
		if err := httpServer.Shutdown(ctx); err != nil {
			return err
		}
		close(chatCommands)
		wg.Wait()
		// This blocks until all RPCs are finished.
		grpcServer.GracefulStop()
		return nil
	case err := <-errC:
		return err
	}
}

// Invoker is a generated function TODO(sr)
func Invoker(context.Context, *grpc.ClientConn, *bread.ChatCommand) error {
	return nil
}
