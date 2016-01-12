
package buildkite

import (
	"time"
	"golang.org/x/net/context"
	"github.com/sr/grpcinstrument"
)


type instrumentedBuildkiteServiceServer struct {
	instrumentator grpcinstrument.Instrumentator
	server BuildkiteServiceServer
}


func NewInstrumentedBuildkiteServiceServer(
	instrumentator grpcinstrument.Instrumentator,
	server BuildkiteServiceServer,
) *instrumentedBuildkiteServiceServer {
	return &instrumentedBuildkiteServiceServer{
		instrumentator,
		server,
	}
}

func (a *instrumentedBuildkiteServiceServer) Status(
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

func (a *instrumentedBuildkiteServiceServer) ListBuilds(
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
