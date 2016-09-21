package bread

import (
	"fmt"

	"github.com/sr/operator"
	"github.com/sr/operator/hipchat"
	"golang.org/x/net/context"

	"bread/pb"
)

type pingAPIServer struct {
	operator.Replier
}

func (s *pingAPIServer) Ping(ctx context.Context, req *breadpb.PingRequest) (*operator.Response, error) {
	return operator.Reply(s, ctx, req, &operator.Message{
		Text: "pong",
		HTML: "<b>pong</b>",
		Options: &operatorhipchat.MessageOptions{
			Color: "gray",
			From:  "pinger.Ping",
		},
	})
}

func (s *pingAPIServer) Otp(ctx context.Context, req *breadpb.OtpRequest) (*operator.Response, error) {
	return operator.Reply(s, ctx, req, &operator.Message{
		Text: "ok",
		HTML: "<b>ok</b>",
		Options: &operatorhipchat.MessageOptions{
			Color: "gray",
			From:  "pinger.Otp",
		},
	})
}

func (s *pingAPIServer) Whoami(ctx context.Context, req *breadpb.WhoamiRequest) (*operator.Response, error) {
	email := req.Request.UserEmail()
	if email == "" {
		email = "unknown"
	}
	return operator.Reply(s, ctx, req, &operator.Message{
		Text: email,
		HTML: fmt.Sprintf(`<a href="mailto:%s">%s</a>`, email, email),
		Options: &operatorhipchat.MessageOptions{
			Color: "gray",
			From:  "pinger.Ping",
		},
	})
}
