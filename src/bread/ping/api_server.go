package breadping

import (
	"github.com/sr/operator"
	"github.com/sr/operator/hipchat"
	"golang.org/x/net/context"
)

type apiServer struct {
	config *PingerConfig
	chat   operator.ChatClient
}

func (s *apiServer) Ping(ctx context.Context, req *PingRequest) (*PingResponse, error) {
	return &PingResponse{}, operator.Reply(ctx, req, &operator.Message{
		Text: "pong",
		HTML: "<b>pong</b>",
		Options: &operatorhipchat.MessageOptions{
			Color: "gray",
			From:  "pinger.Ping",
		},
	}, s.chat)
}
