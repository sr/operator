package protoeasy

import (
	"golang.org/x/net/context"
	"google.golang.org/grpc"
)

type localAPIClient struct {
	apiServer APIServer
}

func newLocalAPIClient(apiServer APIServer) *localAPIClient {
	return &localAPIClient{apiServer}
}

func (a *localAPIClient) Compile(ctx context.Context, request *CompileRequest, _ ...grpc.CallOption) (*CompileResponse, error) {
	return a.apiServer.Compile(ctx, request)
}
