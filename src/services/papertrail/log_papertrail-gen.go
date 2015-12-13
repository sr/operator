
package papertrail

import (
	"time"

	"go.pedge.io/proto/rpclog"
	"golang.org/x/net/context"
)

type logAPIServer struct {
	protorpclog.Logger
	delegate PapertrailServiceServer
}

func NewLogAPIServer(delegate PapertrailServiceServer) *logAPIServer {
	return &logAPIServer{protorpclog.NewLogger("papertrail"), delegate}
}


func (a *logAPIServer) Search(ctx context.Context, request *SearchRequest) (response *SearchResponse, err error) {
	defer func(start time.Time) { a.Log(request, nil, err, time.Since(start)) }(time.Now())
	return a.delegate.Search(ctx, request)
}
