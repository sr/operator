package papertrail

import (
	"github.com/sr/grpcinstrument"
	"golang.org/x/net/context"
	"time"
)

// InstrumentedPapertrailServiceServer implements and instruments PapertrailServiceServer
// using the grpcinstrument package.
type InstrumentedPapertrailServiceServer struct {
	instrumentator grpcinstrument.Instrumentator
	server         PapertrailServiceServer
}

// NewInstrumentedPapertrailServiceServer constructs a instrumentation wrapper for
// PapertrailServiceServer.
func NewInstrumentedPapertrailServiceServer(
	instrumentator grpcinstrument.Instrumentator,
	server PapertrailServiceServer,
) *InstrumentedPapertrailServiceServer {
	return &InstrumentedPapertrailServiceServer{
		instrumentator,
		server,
	}
}

// Search instruments the PapertrailServiceServer.Search method.
func (a *InstrumentedPapertrailServiceServer) Search(
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
