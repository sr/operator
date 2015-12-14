package papertrail

import (
	"github.com/sr/operator/src/grpcinstrument"
	"golang.org/x/net/context"
	"time"
)

type instrumentedAPIServer struct {
	instrumentator grpcinstrument.Instrumentator
	delegate       PapertrailServiceServer
}

func NewInstrumentedAPIServer(
	instrumentator grpcinstrument.Instrumentator,
	delegate PapertrailServiceServer,
) *instrumentedAPIServer {
	return &instrumentedAPIServer{
		instrumentator,
		delegate,
	}
}

func (a *instrumentedAPIServer) Search(
	ctx context.Context,
	request *SearchRequest,
) (response *SearchResponse, err error) {
	defer func(start time.Time) {
		grpcinstrument.Instrument(
			a.instrumentator,
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
