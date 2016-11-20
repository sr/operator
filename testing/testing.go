package testing

import (
	"github.com/sr/operator"
	"golang.org/x/net/context"
)

func NewServer(replier operator.Sender) PingerServer {
	return &server{replier}
}

type server struct {
	operator.Sender
}

func (s *server) Ping(ctx context.Context, req *PingRequest) (*operator.Response, error) {
	return operator.Reply(ctx, s, req, &operator.Message{
		Text: "pong",
		HTML: "<b>pong</b>",
	})
}

func (s *server) PingPong(ctx context.Context, req *PingRequest) (*operator.Response, error) {
	return operator.Reply(ctx, s, req, &operator.Message{
		Text: "pong",
		HTML: "<b>pong</b>",
	})
}
