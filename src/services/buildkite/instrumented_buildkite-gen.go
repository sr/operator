package buildkite

import (
	"github.com/sr/operator/src/grpcinstrument"
	"golang.org/x/net/context"
	"time"
)

type instrumentedBuildkiteServiceServer struct {
	instrumentator grpcinstrument.Instrumentator
	server         BuildkiteServiceServer
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

func (a *instrumentedBuildkiteServiceServer) ProjectsStatus(
	ctx context.Context,
	request *ProjectsStatusRequest,
) (response *ProjectsStatusResponse, err error) {
	defer func(start time.Time) {
		grpcinstrument.Instrument(
			a.instrumentator,
			"buildkite",
			"ProjectsStatus",
			"ProjectsStatusRequest",
			"ProjectsStatusResponse",
			err,
			start,
		)
	}(time.Now())
	return a.server.ProjectsStatus(ctx, request)
}
