package pinger

import (
	"github.com/sr/operator"
	"golang.org/x/net/context"
)

type apiServer struct {
	config *Env
}

func (s *apiServer) Ping(context context.Context, request *PingRequest) (*PingResponse, error) {
	return &PingResponse{
		Output: &operator.Output{
			PlainText: "hello, world",
		},
	}, nil
}
