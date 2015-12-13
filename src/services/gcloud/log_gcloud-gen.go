package gcloud

import (
	"github.com/sr/operator/src/grpclog"
	"golang.org/x/net/context"
	"time"
)

type logAPIServer struct {
	logger   grpclog.Logger
	delegate GCloudServiceServer
}

func NewLogAPIServer(logger grpclog.Logger, delegate GCloudServiceServer) *logAPIServer {
	return &logAPIServer{logger, delegate}
}

func (a *logAPIServer) CreateContainerCluster(ctx context.Context, request *CreateContainerClusterRequest) (response *CreateContainerClusterResponse, err error) {
	defer func(start time.Time) {
		grpclog.Log(
			a.logger,
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

func (a *logAPIServer) ListInstances(ctx context.Context, request *ListInstancesRequest) (response *ListInstancesResponse, err error) {
	defer func(start time.Time) {
		grpclog.Log(
			a.logger,
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
