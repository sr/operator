
package buildkite

import (
	"time"

	"go.pedge.io/proto/rpclog"
	"golang.org/x/net/context"
)

type logAPIServer struct {
	protorpclog.Logger
	delegate BuildkiteServiceServer
}

func NewLogAPIServer(delegate BuildkiteServiceServer) *logAPIServer {
	return &logAPIServer{protorpclog.NewLogger("buildkite"), delegate}
}


func (a *logAPIServer) ProjectsStatus(ctx context.Context, request *ProjectsStatusRequest) (response *ProjectsStatusResponse, err error) {
	defer func(start time.Time) { a.Log(request, nil, err, time.Since(start)) }(time.Now())
	return a.delegate.ProjectsStatus(ctx, request)
}
