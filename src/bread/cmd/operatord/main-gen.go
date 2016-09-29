// Code generated by protoc-gen-operatord
package main

import (
	"github.com/sr/operator"
	"golang.org/x/net/context"
	"google.golang.org/grpc"

	breadpb "bread/pb"
)

func invoker(ctx context.Context, conn *grpc.ClientConn, req *operator.Request) (bool, error) {
	if req.Call.Service == "Deploy" {
		if req.Call.Method == "ListTargets" {
			client := breadpb.NewDeployClient(conn)
			_, err := client.ListTargets(
				ctx,
				&breadpb.ListTargetsRequest{
					Request: req,
				},
			)
			if err != nil {
				return true, err
			}
			return true, nil
		}
		if req.Call.Method == "ListBuilds" {
			client := breadpb.NewDeployClient(conn)
			_, err := client.ListBuilds(
				ctx,
				&breadpb.ListBuildsRequest{
					Request: req,
					Target:  req.Call.Args["target"],
					Branch:  req.Call.Args["branch"],
				},
			)
			if err != nil {
				return true, err
			}
			return true, nil
		}
		if req.Call.Method == "Trigger" {
			client := breadpb.NewDeployClient(conn)
			_, err := client.Trigger(
				ctx,
				&breadpb.TriggerRequest{
					Request: req,
					Target:  req.Call.Args["target"],
					Build:   req.Call.Args["build"],
				},
			)
			if err != nil {
				return true, err
			}
			return true, nil
		}
	}
	if req.Call.Service == "Ping" {
		if req.Call.Method == "Otp" {
			client := breadpb.NewPingClient(conn)
			_, err := client.Otp(
				ctx,
				&breadpb.OtpRequest{
					Request: req,
				},
			)
			if err != nil {
				return true, err
			}
			return true, nil
		}
		if req.Call.Method == "Ping" {
			client := breadpb.NewPingClient(conn)
			_, err := client.Ping(
				ctx,
				&breadpb.PingRequest{
					Request: req,
					Arg1:    req.Call.Args["arg1"],
				},
			)
			if err != nil {
				return true, err
			}
			return true, nil
		}
		if req.Call.Method == "SlowLoris" {
			client := breadpb.NewPingClient(conn)
			_, err := client.SlowLoris(
				ctx,
				&breadpb.SlowLorisRequest{
					Request: req,
				},
			)
			if err != nil {
				return true, err
			}
			return true, nil
		}
		if req.Call.Method == "Whoami" {
			client := breadpb.NewPingClient(conn)
			_, err := client.Whoami(
				ctx,
				&breadpb.WhoamiRequest{
					Request: req,
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
