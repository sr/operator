// Code generated by protoc-gen-operatord
package main

import (
	"time"

	"github.com/sr/grpcinstrument"
	"golang.org/x/net/context"

	servicepkg "services/buildkite"
)

type instrumented_buildkite_BuildkiteService struct {
	instrumentator grpcinstrument.Instrumentator
	server         servicepkg.BuildkiteServiceServer
}


// Status instruments the BuildkiteService.Status method.
func (a *instrumented_buildkite_BuildkiteService) Status(
	ctx context.Context,
	request *servicepkg.StatusRequest,
) (response *servicepkg.StatusResponse, err error) {
	defer func(start time.Time) {
		grpcinstrument.Instrument(
			a.instrumentator,
			"buildkite",
			"Status",
			"StatusRequest",
			"StatusResponse",
			err,
			start,
		)
	}(time.Now())
	return a.server.Status(ctx, request)
}

// ListBuilds instruments the BuildkiteService.ListBuilds method.
func (a *instrumented_buildkite_BuildkiteService) ListBuilds(
	ctx context.Context,
	request *servicepkg.ListBuildsRequest,
) (response *servicepkg.ListBuildsResponse, err error) {
	defer func(start time.Time) {
		grpcinstrument.Instrument(
			a.instrumentator,
			"buildkite",
			"ListBuilds",
			"ListBuildsRequest",
			"ListBuildsResponse",
			err,
			start,
		)
	}(time.Now())
	return a.server.ListBuilds(ctx, request)
}
