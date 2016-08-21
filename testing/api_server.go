package operatortesting

import (
	"github.com/sr/operator"
	"golang.org/x/net/context"
)

type apiServer struct {
	config *PingerConfig
	chat   operator.ChatClient
}

func (s *apiServer) Ping(ctx context.Context, req *PingRequest) (*operator.Response, error) {
	return operator.Reply(ctx, req, &operator.Message{
		Text: "pong",
		HTML: "<b>pong</b>",
	}, s.chat)
}
