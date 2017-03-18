// Command eventsd is the events.dev.pardot.com HTTP server.
package main

import (
	"context"
	"errors"
	"flag"
	"fmt"
	"log"
	"net/http"
	"net/url"
	"os"
	"os/signal"
	"strings"
	"time"

	"git.dev.pardot.com/Pardot/bread"
)

var (
	port         = flag.String("port", "", "Listening port of the HTTP server. Defaults to $PORT.")
	githubSecret = flag.String("github-secret", "", "Secret token used to verify the signature of webhook requests received from GitHub")
)

func main() {
	if err := run(); err != nil {
		fmt.Fprintf(os.Stderr, "eventsd: %s\n", err)
		os.Exit(1)
	}
}

func run() error {
	// Allow setting flags via environment variables
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
	if *githubSecret == "" {
		return errors.New("required flag missing: github-secret")
	}

	logger := log.New(os.Stderr, "eventsd: ", 0)
	handler, err := bread.NewEventHandler(
		logger,
		&bread.EventHandlerConfig{
			GithubSecretToken: *githubSecret,
			GithubEndpoints: []*url.URL{
				mustParseURL("https://compliance.dev.pardot.com/webhooks"),
			},
			JIRAEndpoints: []*url.URL{
				mustParseURL("https://compliance.dev.pardot.com/events/jira"),
			},
			RequestTimeout: 2.0 * time.Second,
			MaxRetries:     5,
			RetryDelay:     1.0 * time.Second,
		},
	)
	if err != nil {
		return err
	}

	server := &http.Server{
		Addr:     fmt.Sprintf(":%s", *port),
		Handler:  handler,
		ErrorLog: logger,
	}

	stopC := make(chan os.Signal)
	errC := make(chan error, 1)
	signal.Notify(stopC, os.Interrupt)

	go func() {
		errC <- server.ListenAndServe()
	}()

	select {
	case <-stopC:
		logger.Printf("shutting down...")
		ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
		defer cancel()
		return server.Shutdown(ctx)
	case err := <-errC:
		return err
	}
}

func mustParseURL(s string) *url.URL {
	u, err := url.Parse(s)
	if err != nil {
		panic(err)
	}
	return u
}
