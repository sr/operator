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
	listener, err := net.Listen("tcp", ":3000")
	if err != nil {
		return err
	}
	server := grpc.NewServer()

	gcloud.RegisterGCloudServiceServer(server, gcloud.NewAPIServer())

	papertrailEnv := &papertrail.Env{}
	if err := env.Populate(papertrailEnv); err != nil {
		return err
	}
	papertrail.RegisterPapertrailServiceServer(
		server,
		papertrail.NewAPIServer(papertrailEnv),
	)

	return server.Serve(listener)
}

func main() {
	if err := run(); err != nil {
		fmt.Fprintf(os.Stderr, "operatord error: %v", err)
		os.Exit(1)
	}
}
