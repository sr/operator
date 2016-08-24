package operatortesting

import (
	"github.com/sr/operator"
	"golang.org/x/net/context"
)

type apiServer struct {
	operator.Replier
	config *PingerConfig
}

func (s *apiServer) Ping(ctx context.Context, req *PingRequest) (*operator.Response, error) {
	return operator.Reply(s, ctx, req, &operator.Message{
		Text: "pong",
		HTML: "<b>pong</b>",
	})
}
