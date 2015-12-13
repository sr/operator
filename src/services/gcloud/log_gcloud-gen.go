package gcloud

import (
	"time"

	"github.com/rcrowley/go-metrics"
	"github.com/sr/operator/src/grpclog"
	"golang.org/x/net/context"
)

type logAPIServer struct {
	logger   grpclog.Logger
	metrics  metrics.Registry
	delegate GCloudServiceServer
}

func NewLogAPIServer(
	logger grpclog.Logger,
	metrics metrics.Registry,
	delegate GCloudServiceServer,
) *logAPIServer {
	return &logAPIServer{logger, metrics, delegate}
}

func (a *logAPIServer) CreateContainerCluster(
	ctx context.Context,
	request *CreateContainerClusterRequest,
) (response *CreateContainerClusterResponse, err error) {
	defer func(start time.Time) {
		grpclog.Instrument(
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

func (a *logAPIServer) ListInstances(
	ctx context.Context,
	request *ListInstancesRequest,
) (response *ListInstancesResponse, err error) {
	defer func(start time.Time) {
		grpclog.Instrument(
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
