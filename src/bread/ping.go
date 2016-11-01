package bread

import (
	"strconv"
	"time"

	"github.com/sr/operator"
	"github.com/sr/operator/hipchat"
	"golang.org/x/net/context"

	"bread/pb"
)

type pingAPIServer struct {
	operator.Sender
}

func (s *pingAPIServer) Ping(ctx context.Context, req *breadpb.PingRequest) (*operator.Response, error) {
	return operator.Reply(ctx, s, req, &operator.Message{
		Text: "pong",
		HTML: "<b>pong</b>",
		Options: &operatorhipchat.MessageOptions{
			Color: "gray",
			From:  "pinger.Ping",
		},
	})
}

func (s *pingAPIServer) SlowLoris(ctx context.Context, req *breadpb.SlowLorisRequest) (*operator.Response, error) {
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
