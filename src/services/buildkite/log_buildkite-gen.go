
package buildkite

import (
	"time"
	"golang.org/x/net/context"
	"github.com/sr/operator/src/grpcinstrument"
	"github.com/rcrowley/go-metrics"
)

type instrumentedAPIServer struct {
	logger grpcinstrument.Logger
	metrics metrics.Registry
	delegate BuildkiteServiceServer
}

func NewInstrumentedAPIServer(
	logger grpcinstrument.Logger,
	metrics metrics.Registry,
	delegate BuildkiteServiceServer,
) *instrumentedAPIServer {
	return &instrumentedAPIServer{logger, metrics, delegate}
}


func (a *instrumentedAPIServer) ProjectsStatus(
	ctx context.Context,
	request *ProjectsStatusRequest,
) (response *ProjectsStatusResponse, err error) {
	defer func(start time.Time) {
		grpcinstrument.Instrument(
			a.logger,
			a.metrics,
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
