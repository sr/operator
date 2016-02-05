package buildkite

import (
	"github.com/sr/grpcinstrument"
	"golang.org/x/net/context"
	"time"
)

// InstrumentedBuildkiteServiceServer implements and instruments BuildkiteServiceServer
// using the grpcinstrument package.
type InstrumentedBuildkiteServiceServer struct {
	instrumentator grpcinstrument.Instrumentator
	server         BuildkiteServiceServer
}

// NewInstrumentedBuildkiteServiceServer constructs a instrumentation wrapper for
// BuildkiteServiceServer.
func NewInstrumentedBuildkiteServiceServer(
	instrumentator grpcinstrument.Instrumentator,
	server BuildkiteServiceServer,
) *InstrumentedBuildkiteServiceServer {
	return &InstrumentedBuildkiteServiceServer{
		instrumentator,
		server,
	}
}

// Status instruments the BuildkiteServiceServer.Status method.
func (a *InstrumentedBuildkiteServiceServer) Status(
	ctx context.Context,
	request *StatusRequest,
) (response *StatusResponse, err error) {
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

// ListBuilds instruments the BuildkiteServiceServer.ListBuilds method.
func (a *InstrumentedBuildkiteServiceServer) ListBuilds(
	ctx context.Context,
	request *ListBuildsRequest,
) (response *ListBuildsResponse, err error) {
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
