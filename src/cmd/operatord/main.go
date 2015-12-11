package main

import (
	"fmt"
	"net"
	"os"

	"github.com/sr/operator/src/services/buildkite"
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
	if gcloudServer, err := gcloud.NewAPIServer(); err != nil {
		return err
	} else {
		gcloud.RegisterGCloudServiceServer(server, gcloudServer)
	}
	papertrailEnv := &papertrail.Env{}
	if err := env.Populate(papertrailEnv); err != nil {
		return err
	}
	papertrail.RegisterPapertrailServiceServer(
		server,
		papertrail.NewAPIServer(papertrailEnv),
	)
	buildkiteEnv := &buildkite.Env{}
	if err := env.Populate(buildkiteEnv); err != nil {
		return err
	}
	if buildkiteServer, err := buildkite.NewServer(buildkiteEnv); err != nil {
		return err
	} else {
		buildkite.RegisterBuildkiteServiceServer(server, buildkiteServer)
	}
	fmt.Println("listening on port 3000")
	return server.Serve(listener)
}

func main() {
	if err := run(); err != nil {
		fmt.Fprintf(os.Stderr, "operatord error: %v\n", err)
		os.Exit(1)
	}
}
