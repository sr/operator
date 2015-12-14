package gcloud

import (
	"github.com/sr/operator/src/grpcinstrument"
	"golang.org/x/net/context"
	"time"
)

type instrumentedGCloudServiceServer struct {
	instrumentator grpcinstrument.Instrumentator
	delegate       GCloudServiceServer
}

func NewInstrumentedGCloudServiceServer(
	instrumentator grpcinstrument.Instrumentator,
	delegate GCloudServiceServer,
) *instrumentedGCloudServiceServer {
	return &instrumentedGCloudServiceServer{
		instrumentator,
		delegate,
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
	return a.delegate.CreateContainerCluster(ctx, request)
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
	return a.delegate.ListInstances(ctx, request)
}
