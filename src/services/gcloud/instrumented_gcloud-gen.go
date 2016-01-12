
package gcloud

import (
	"time"
	"golang.org/x/net/context"
	"github.com/sr/grpcinstrument"
)


type instrumentedGcloudServiceServer struct {
	instrumentator grpcinstrument.Instrumentator
	server GcloudServiceServer
}


func NewInstrumentedGcloudServiceServer(
	instrumentator grpcinstrument.Instrumentator,
	server GcloudServiceServer,
) *instrumentedGcloudServiceServer {
	return &instrumentedGcloudServiceServer{
		instrumentator,
		server,
	}
}

func (a *instrumentedGcloudServiceServer) CreateContainerCluster(
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

func (a *instrumentedGcloudServiceServer) ListInstances(
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
