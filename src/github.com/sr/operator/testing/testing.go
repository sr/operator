package operatortesting

import (
	"github.com/sr/operator"
	"golang.org/x/net/context"
)

func NewServer(replier operator.Replier) PingerServer {
	return &server{replier}
}

type server struct {
	operator.Replier
}

func (s *server) Ping(ctx context.Context, req *PingRequest) (*operator.Response, error) {
	return operator.Reply(s, ctx, req, &operator.Message{
		Text: "pong",
		HTML: "<b>pong</b>",
	})
}

func (s *server) PingPong(ctx context.Context, req *PingRequest) (*operator.Response, error) {
	return operator.Reply(s, ctx, req, &operator.Message{
		Text: "pong",
		HTML: "<b>pong</b>",
	})
}
