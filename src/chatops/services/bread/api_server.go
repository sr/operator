package bread

import "golang.org/x/net/context"

type apiServer struct {
}

func newAPIServer(config *BreadConfig) (*apiServer, error) {
	return &apiServer{}, nil
}

func (s *apiServer) EcsDeploy(ctx context.Context, in *EcsDeployRequest) (*EcsDeployResponse, error) {
	return nil, nil
}
