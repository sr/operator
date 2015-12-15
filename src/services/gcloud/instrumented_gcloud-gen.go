package gcloud

import (
	"github.com/sr/operator/src/grpcinstrument"
	"golang.org/x/net/context"
	"time"
)

type instrumentedGCloudServiceServer struct {
	instrumentator grpcinstrument.Instrumentator
	server         GCloudServiceServer
}

func NewInstrumentedGCloudServiceServer(
	instrumentator grpcinstrument.Instrumentator,
	server GCloudServiceServer,
) *instrumentedGCloudServiceServer {
	return &instrumentedGCloudServiceServer{
		instrumentator,
		server,
	}
}

func (a *instrumentedGCloudServiceServer) CreateContainerCluster(
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

func (a *instrumentedGCloudServiceServer) ListInstances(
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
