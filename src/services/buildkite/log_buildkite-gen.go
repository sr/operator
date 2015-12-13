package buildkite

import (
	"time"

	"github.com/rcrowley/go-metrics"
	"github.com/sr/operator/src/grpclog"
	"golang.org/x/net/context"
)

type logAPIServer struct {
	logger   grpclog.Logger
	metrics  metrics.Registry
	delegate BuildkiteServiceServer
}

func NewLogAPIServer(
	logger grpclog.Logger,
	metrics metrics.Registry,
	delegate BuildkiteServiceServer,
) *logAPIServer {
	return &logAPIServer{logger, metrics, delegate}
}

func (a *logAPIServer) ProjectsStatus(
	ctx context.Context,
	request *ProjectsStatusRequest,
) (response *ProjectsStatusResponse, err error) {
	defer func(start time.Time) {
		grpclog.Instrument(
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
