package buildkite

import (
	"github.com/sr/operator/src/grpcinstrument"
	"golang.org/x/net/context"
	"time"
)

type instrumentedAPIServer struct {
	instrumentator grpcinstrument.Instrumentator
	delegate       BuildkiteServiceServer
}

func NewInstrumentedAPIServer(
	instrumentator grpcinstrument.Instrumentator,
	delegate BuildkiteServiceServer,
) *instrumentedAPIServer {
	return &instrumentedAPIServer{
		instrumentator,
		delegate,
	}
}

func (a *instrumentedAPIServer) ProjectsStatus(
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
	return a.delegate.ProjectsStatus(ctx, request)
}
