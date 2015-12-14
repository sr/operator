package gcloud

import (
	"github.com/rcrowley/go-metrics"
	"github.com/sr/operator/src/grpcinstrument"
	"golang.org/x/net/context"
	"time"
)

type instrumentedAPIServer struct {
	logger   grpcinstrument.Logger
	metrics  metrics.Registry
	delegate GCloudServiceServer
}

func NewInstrumentedAPIServer(
	logger grpcinstrument.Logger,
	metrics metrics.Registry,
	delegate GCloudServiceServer,
) *instrumentedAPIServer {
	return &instrumentedAPIServer{logger, metrics, delegate}
}

func (a *instrumentedAPIServer) CreateContainerCluster(
	ctx context.Context,
	request *CreateContainerClusterRequest,
) (response *CreateContainerClusterResponse, err error) {
	defer func(start time.Time) {
		grpcinstrument.Instrument(
			a.logger,
			a.metrics,
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

func (a *instrumentedAPIServer) ListInstances(
	ctx context.Context,
	request *ListInstancesRequest,
) (response *ListInstancesResponse, err error) {
	defer func(start time.Time) {
		grpcinstrument.Instrument(
			a.logger,
			a.metrics,
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
