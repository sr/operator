package papertrail

import (
	"github.com/sr/grpcinstrument"
	"golang.org/x/net/context"
	"time"
)

type instrumentedPapertrailServiceServer struct {
	instrumentator grpcinstrument.Instrumentator
	server         PapertrailServiceServer
}

func NewInstrumentedPapertrailServiceServer(
	instrumentator grpcinstrument.Instrumentator,
	server PapertrailServiceServer,
) *instrumentedPapertrailServiceServer {
	return &instrumentedPapertrailServiceServer{
		instrumentator,
		server,
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
	return a.server.Search(ctx, request)
}
