package main

import (
	"bread/ping"

	"github.com/sr/operator"
	"golang.org/x/net/context"
	"google.golang.org/grpc"
)

func invoker(conn *grpc.ClientConn, req *operator.Request) (bool, error) {
	if req.Call.Service == "ping" && req.Call.Method == "ping" {
		c := breadping.NewPingerClient(conn)
		_, err := c.Ping(
			context.Background(),
			&breadping.PingRequest{
				Source: req.Source,
			},
		)
		if err != nil {
			return true, err
		}
	}
	return false, nil
}
