package breadping

import (
	"github.com/sr/operator"
	"golang.org/x/net/context"
)

type apiServer struct {
	config *PingerConfig
}

func (s *apiServer) Ping(context context.Context, request *PingRequest) (*PingResponse, error) {
	return &PingResponse{
		Output: &operator.Output{
			PlainText: "pong",
		},
	}, nil
}
