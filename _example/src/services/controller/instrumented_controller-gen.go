
package controller

import (
	"github.com/sr/grpcinstrument"
	"golang.org/x/net/context"
	"time"
)


// InstrumentedControllerServer implements and instruments ControllerServer
// using the grpcinstrument package.
type InstrumentedControllerServer struct {
	instrumentator grpcinstrument.Instrumentator
	server         ControllerServer
}


// NewInstrumentedControllerServer constructs a instrumentation wrapper for
// ControllerServer.
func NewInstrumentedControllerServer(
	instrumentator grpcinstrument.Instrumentator,
	server ControllerServer,
) *InstrumentedControllerServer {
	return &InstrumentedControllerServer{
		instrumentator,
		server,
	}
}

// CreateCluster instruments the ControllerServer.CreateCluster method.
func (a *InstrumentedControllerServer) CreateCluster(
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

// Deploy instruments the ControllerServer.Deploy method.
func (a *InstrumentedControllerServer) Deploy(
	ctx context.Context,
	request *DeployRequest,
) (response *DeployResponse, err error) {
	defer func(start time.Time) {
		grpcinstrument.Instrument(
			a.instrumentator,
			"controller",
			"Deploy",
			"DeployRequest",
			"DeployResponse",
			err,
			start,
		)
	}(time.Now())
	return a.server.Deploy(ctx, request)
}
