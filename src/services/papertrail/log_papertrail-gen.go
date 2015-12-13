
package papertrail

import (
	"time"
	"golang.org/x/net/context"
	"github.com/sr/operator/src/grpclog"
)

type logAPIServer struct {
	logger grpclog.Logger
	delegate PapertrailServiceServer
}

func NewLogAPIServer(logger grpclog.Logger, delegate PapertrailServiceServer) *logAPIServer {
	return &logAPIServer{logger, delegate}
}


func (a *logAPIServer) Search(ctx context.Context, request *SearchRequest) (response *SearchResponse, err error) {
	defer func(start time.Time) {
		grpclog.Log(
			a.logger,
			"papertrail",
			"Search",
			"SearchRequest",
			"SearchResponse",
			err,
			start,
		)
	}(time.Now())
	return a.delegate.Search(ctx, request)
}
