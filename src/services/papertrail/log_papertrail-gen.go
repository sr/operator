package papertrail

import (
	"github.com/rcrowley/go-metrics"
	"github.com/sr/operator/src/grpclog"
	"golang.org/x/net/context"
	"time"
)

type logAPIServer struct {
	logger   grpclog.Logger
	metrics  metrics.Registry
	delegate PapertrailServiceServer
}

func NewLogAPIServer(
	logger grpclog.Logger,
	metrics metrics.Registry,
	delegate PapertrailServiceServer,
) *logAPIServer {
	return &logAPIServer{logger, metrics, delegate}
}

func (a *logAPIServer) Search(
	ctx context.Context,
	request *SearchRequest,
) (response *SearchResponse, err error) {
	defer func(start time.Time) {
		grpclog.Instrument(
			a.logger,
			a.metrics,
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
