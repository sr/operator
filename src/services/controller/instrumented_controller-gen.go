
package controller

import (
	"time"
	"golang.org/x/net/context"
	"github.com/sr/grpcinstrument"
)


type instrumentedControllerServer struct {
	instrumentator grpcinstrument.Instrumentator
	server ControllerServer
}


func NewInstrumentedControllerServer(
	instrumentator grpcinstrument.Instrumentator,
	server ControllerServer,
) *instrumentedControllerServer {
	return &instrumentedControllerServer{
		instrumentator,
		server,
	}
}

func (a *instrumentedControllerServer) CreateCluster(
	ctx context.Context,
	request *CreateClusterRequest,
) (response *CreateClusterResponse, err error) {
	defer func(start time.Time) {
		grpcinstrument.Instrument(
			a.instrumentator,
			"controller",
			"CreateCluster",
			"CreateClusterRequest",
			"CreateClusterResponse",
			err,
			start,
		)
	}(time.Now())
	return a.server.CreateCluster(ctx, request)
}
