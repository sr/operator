// Code generated by protoc-gen-operatord.
package main

import (
	"os"

	buildkite "github.com/sr/operator/src/services/buildkite"

	gcloud "github.com/sr/operator/src/services/gcloud"

	papertrail "github.com/sr/operator/src/services/papertrail"

	"github.com/rcrowley/go-metrics"
	"github.com/sr/operator/src/operator"
	"go.pedge.io/env"
)

func run() error {
	config := &operator.Config{}
	if err := env.Populate(config); err != nil {
		return err
	}
	server := operator.NewServer(config.Address)

	buildkiteEnv := &buildkite.Env{}
	if err := env.Populate(buildkiteEnv); err != nil {
		operator.LogServiceStartupError("buildkite", err)
	} else {
		if buildkiteServer, err := buildkite.NewAPIServer(buildkiteEnv); err != nil {
			operator.LogServiceStartupError("buildkite", err)
		} else {
			instrumented := buildkite.NewInstrumentedAPIServer(
				operator.GRPCLogger,
				metrics.DefaultRegistry,
				buildkiteServer,
			)
			buildkite.RegisterBuildkiteServiceServer(server.Server(), instrumented)
		}
	}

	gcloudEnv := &gcloud.Env{}
	if err := env.Populate(gcloudEnv); err != nil {
		operator.LogServiceStartupError("gcloud", err)
	} else {
		if gcloudServer, err := gcloud.NewAPIServer(gcloudEnv); err != nil {
			operator.LogServiceStartupError("gcloud", err)
		} else {
			instrumented := gcloud.NewInstrumentedAPIServer(
				operator.GRPCLogger,
				metrics.DefaultRegistry,
				gcloudServer,
			)
			gcloud.RegisterGCloudServiceServer(server.Server(), instrumented)
		}
	}

	papertrailEnv := &papertrail.Env{}
	if err := env.Populate(papertrailEnv); err != nil {
		operator.LogServiceStartupError("papertrail", err)
	} else {
		if papertrailServer, err := papertrail.NewAPIServer(papertrailEnv); err != nil {
			operator.LogServiceStartupError("papertrail", err)
		} else {
			instrumented := papertrail.NewInstrumentedAPIServer(
				operator.GRPCLogger,
				metrics.DefaultRegistry,
				papertrailServer,
			)
			papertrail.RegisterPapertrailServiceServer(server.Server(), instrumented)
		}
	}

	return server.Serve()
}

func main() {
	if err := run(); err != nil {
		operator.LogServerStartupError(err)
		os.Exit(1)
	}
}
