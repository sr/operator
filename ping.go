package bread

import (
	"fmt"
	"strconv"
	"time"

	"git.dev.pardot.com/Pardot/bread/pb"
	"github.com/sr/operator"
	"github.com/sr/operator/hipchat"
	"golang.org/x/net/context"
)

type pingServer struct {
	operator.Sender
}

// NewPingServer returns a gRPC server that implements the breadpb.PingServer
// interface.
func NewPingServer(sender operator.Sender) breadpb.PingServer {
	return &pingServer{sender}
}

func (s *pingServer) Ping(ctx context.Context, req *breadpb.PingRequest) (*operator.Response, error) {
	email := operator.GetUserEmail(req)
	if email == "" {
		email = "unknown"
	}
	return operator.Reply(ctx, s, req, &operator.Message{
		Text: fmt.Sprintf("PONG %s", email),
		HTML: fmt.Sprintf(`PONG <a href="mailto:%s">%s</a>`, email, email),
		Options: &operatorhipchat.MessageOptions{
			Color: "gray",
			From:  "pinger.Ping",
		},
	})
}

func (s *pingServer) SlowLoris(ctx context.Context, req *breadpb.SlowLorisRequest) (*operator.Response, error) {
	var dur time.Duration
	if req.Wait == "" {
		dur = 10 * time.Second
	} else {
		i, err := strconv.Atoi(req.Wait)
		if err != nil {
			return nil, err
		}
		dur = time.Duration(i) * time.Second
	}
	time.Sleep(dur)
	return operator.Reply(ctx, s, req, &operator.Message{
		Text: "https://66.media.tumblr.com/500736338e23d5b5adb0201b6b74cbc9/tumblr_mmyemrrqkq1s1fx0zo1_500.gif",
		Options: &operatorhipchat.MessageOptions{
			Color: "gray",
			From:  "pinger.SlowLoris",
		},
	})
}
