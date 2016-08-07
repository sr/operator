package main

import (
	"bread/ping"

	"github.com/sr/operator"
	"golang.org/x/net/context"
	"google.golang.org/grpc"
)

func invoker(conn *grpc.ClientConn, call string, msg *operator.Message) (bool, error) {
	switch call {
	case "ping ping":
		c := breadping.NewPingerClient(conn)
		_, err := c.Ping(
			context.Background(),
			&breadping.PingRequest{
				Source: msg.Source,
			},
		)
		if err != nil {
			return true, err
		}
	}
	return false, nil
}
