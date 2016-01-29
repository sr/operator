
package gcloud

import (
	"github.com/sr/grpcinstrument"
	"golang.org/x/net/context"
	"time"
)


// InstrumentedGcloudServiceServer implements and instruments GcloudServiceServer
// using the grpcinstrument package.
type InstrumentedGcloudServiceServer struct {
	instrumentator grpcinstrument.Instrumentator
	server         GcloudServiceServer
}


// NewInstrumentedGcloudServiceServer constructs a instrumentation wrapper for
// GcloudServiceServer.
func NewInstrumentedGcloudServiceServer(
	instrumentator grpcinstrument.Instrumentator,
	server GcloudServiceServer,
) *InstrumentedGcloudServiceServer {
	return &InstrumentedGcloudServiceServer{
		instrumentator,
		server,
	}
}

// CreateContainerCluster instruments the GcloudServiceServer.CreateContainerCluster method.
func (a *InstrumentedGcloudServiceServer) CreateContainerCluster(
	ctx context.Context,
	request *CreateContainerClusterRequest,
) (response *CreateContainerClusterResponse, err error) {
	defer func(start time.Time) {
		grpcinstrument.Instrument(
			a.instrumentator,
			"gcloud",
			"CreateContainerCluster",
			"CreateContainerClusterRequest",
			"CreateContainerClusterResponse",
			err,
			start,
		)
	}(time.Now())
	return a.server.CreateContainerCluster(ctx, request)
}

// ListInstances instruments the GcloudServiceServer.ListInstances method.
func (a *InstrumentedGcloudServiceServer) ListInstances(
	ctx context.Context,
	request *ListInstancesRequest,
) (response *ListInstancesResponse, err error) {
	defer func(start time.Time) {
		grpcinstrument.Instrument(
			a.instrumentator,
			"gcloud",
			"ListInstances",
			"ListInstancesRequest",
			"ListInstancesResponse",
			err,
			start,
		)
	}(time.Now())
	return a.server.ListInstances(ctx, request)
}
