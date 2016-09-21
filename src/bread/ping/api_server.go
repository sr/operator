package breadping

import (
	"fmt"

	"github.com/sr/operator"
	"github.com/sr/operator/hipchat"
	"golang.org/x/net/context"
)

type apiServer struct {
	operator.Replier
}

func (s *apiServer) Ping(ctx context.Context, req *PingRequest) (*operator.Response, error) {
	return operator.Reply(s, ctx, req, &operator.Message{
		Text: "pong",
		HTML: "<b>pong</b>",
		Options: &operatorhipchat.MessageOptions{
			Color: "gray",
			From:  "pinger.Ping",
		},
	})
}

func (s *apiServer) Otp(ctx context.Context, req *OtpRequest) (*operator.Response, error) {
	return operator.Reply(s, ctx, req, &operator.Message{
		Text: "ok",
		HTML: "<b>ok</b>",
		Options: &operatorhipchat.MessageOptions{
			Color: "gray",
			From:  "pinger.Otp",
		},
	})
}

func (s *apiServer) Whoami(ctx context.Context, req *WhoamiRequest) (*operator.Response, error) {
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
