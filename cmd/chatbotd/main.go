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
	"os"
	"os/signal"
	"strings"
	"time"

	"git.dev.pardot.com/Pardot/bread"

	"google.golang.org/grpc"
)

var (
	port = flag.String("port", "", "Listening port of the HTTP server. Defaults to $PORT.")
)

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

	httpServer := &http.Server{
		Addr:     fmt.Sprintf(":%s", *port),
		ErrorLog: logger,
		Handler:  bread.NewPingHandler(nil),
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
