package main

import (
	"fmt"
	"net"
	"os"

	"github.com/sr/operator/src/services/gcloud"
	"github.com/sr/operator/src/services/papertrail"
	"go.pedge.io/env"
	"google.golang.org/grpc"
)

func run() error {
	// TODO: configure server port via environment variable
	listener, err := net.Listen("tcp", ":3000")
	if err != nil {
		return err
	}
	server := grpc.NewServer()
	// TODO: figure out how to autoload services... generate?
	gcloudServer, err := gcloud.NewAPIServer()
	if err != nil {
		return err
	}
	gcloud.RegisterGCloudServiceServer(server, gcloudServer)
	papertrailEnv := &papertrail.Env{}
	if err := env.Populate(papertrailEnv); err != nil {
		return err
	}
	papertrail.RegisterPapertrailServiceServer(
		server,
		papertrail.NewAPIServer(papertrailEnv),
	)
	fmt.Println("listening on port 3000")
	return server.Serve(listener)
}

func main() {
	if err := run(); err != nil {
		fmt.Fprintf(os.Stderr, "operatord error: %v\n", err)
		os.Exit(1)
	}
}
