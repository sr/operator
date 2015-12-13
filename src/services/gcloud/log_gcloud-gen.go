
package gcloud

import (
	"time"

	"go.pedge.io/proto/rpclog"
	"golang.org/x/net/context"
)

type logAPIServer struct {
	protorpclog.Logger
	delegate GCloudServiceServer
}

func NewLogAPIServer(delegate GCloudServiceServer) *logAPIServer {
	return &logAPIServer{protorpclog.NewLogger("gcloud"), delegate}
}


func (a *logAPIServer) CreateContainerCluster(ctx context.Context, request *CreateContainerClusterRequest) (response *CreateContainerClusterResponse, err error) {
	defer func(start time.Time) { a.Log(request, nil, err, time.Since(start)) }(time.Now())
	return a.delegate.CreateContainerCluster(ctx, request)
}

func (a *logAPIServer) ListInstances(ctx context.Context, request *ListInstancesRequest) (response *ListInstancesResponse, err error) {
	defer func(start time.Time) { a.Log(request, nil, err, time.Since(start)) }(time.Now())
	return a.delegate.ListInstances(ctx, request)
}
