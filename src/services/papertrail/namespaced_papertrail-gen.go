package papertrail

import (
	"github.com/sr/operator/src/grpcinstrument"
	"golang.org/x/net/context"
	"time"
)

type instrumentedPapertrailServiceServer struct {
	instrumentator grpcinstrument.Instrumentator
	delegate       PapertrailServiceServer
}

func NewInstrumentedPapertrailServiceServer(
	instrumentator grpcinstrument.Instrumentator,
	delegate PapertrailServiceServer,
) *instrumentedPapertrailServiceServer {
	return &instrumentedPapertrailServiceServer{
		instrumentator,
		delegate,
	}
}

func (a *instrumentedPapertrailServiceServer) Search(
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
