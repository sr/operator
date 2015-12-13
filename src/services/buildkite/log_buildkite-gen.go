
package buildkite

import (
	"time"
	"golang.org/x/net/context"
	"github.com/sr/operator/src/grpclog"
)

type logAPIServer struct {
	logger grpclog.Logger
	delegate BuildkiteServiceServer
}

func NewLogAPIServer(logger grpclog.Logger, delegate BuildkiteServiceServer) *logAPIServer {
	return &logAPIServer{logger, delegate}
}


func (a *logAPIServer) ProjectsStatus(ctx context.Context, request *ProjectsStatusRequest) (response *ProjectsStatusResponse, err error) {
	defer func(start time.Time) {
		grpclog.Log(
			a.logger,
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
