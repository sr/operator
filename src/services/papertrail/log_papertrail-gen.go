
package papertrail

import (
	"time"
	"golang.org/x/net/context"
	"github.com/sr/operator/src/grpcinstrument"
	"github.com/rcrowley/go-metrics"
)

type instrumentedAPIServer struct {
	logger grpcinstrument.Logger
	metrics metrics.Registry
	delegate PapertrailServiceServer
}

func NewInstrumentedAPIServer(
	logger grpcinstrument.Logger,
	metrics metrics.Registry,
	delegate PapertrailServiceServer,
) *instrumentedAPIServer {
	return &instrumentedAPIServer{logger, metrics, delegate}
}


func (a *instrumentedAPIServer) Search(
	ctx context.Context,
	request *SearchRequest,
) (response *SearchResponse, err error) {
	defer func(start time.Time) {
		grpcinstrument.Instrument(
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
