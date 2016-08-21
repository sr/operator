// Code generated by protoc-gen-operatord
package main

import (
	"errors"
	"flag"
	"os"
	"strings"

	"github.com/sr/operator"
	"golang.org/x/net/context"
	"google.golang.org/grpc"

	ping "bread/ping"
)

func buildOperatorServer(
	chat operator.ChatClient,
	server *grpc.Server,
	flags *flag.FlagSet,
) (map[string]error, error) {
	pingConfig := &ping.PingerConfig{}
	services := make(map[string]error)
	if err := flags.Parse(os.Args[1:]); err != nil {
		return services, err
	}
	errs := make(map[string][]string)
	if len(errs["ping"]) != 0 {
		services["ping"] = errors.New("required flag(s) missing: " + strings.Join(errs["ping"], ", "))
	} else {
		pingServer, err := ping.NewAPIServer(chat, pingConfig)
		if err != nil {
			services["ping"] = err
		} else {
			ping.RegisterPingerServer(server, pingServer)
			services["ping"] = nil
		}
	}
	return services, nil
}

func invoker(ctx context.Context, conn *grpc.ClientConn, req *operator.Request, args map[string]string) (bool, error) {
	if req.Call.Service == "ping" {
		if req.Call.Method == "ping" {
			client := ping.NewPingerClient(conn)
			_, err := client.Ping(
				ctx,
				&ping.PingRequest{
					Source: req.Source,
					Arg1:   args["arg1"],
				},
			)
			if err != nil {
				return true, err
			}
			return true, nil
		}
	}
	return false, nil
}
