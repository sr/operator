// Code generated by protoc-gen-operatorcmd
package main

import (
	"flag"
	"fmt"
	"io"
	"os"

	"github.com/sr/operator"
	"golang.org/x/net/context"

	breadpb "bread/pb"
)

const program = "operatorctl"

var cmd = operator.NewCommand(
	program,
	[]operator.ServiceCommand{
		{
			Name:     "deploy",
			Synopsis: `Deploy any of the projects listed on Canoe and internal apps hosted AWS/ECS`,
			Methods: []operator.MethodCommand{
				{
					Name:     "list-targets",
					Synopsis: `List what can be deployed`,
					Flags:    []*flag.Flag{},
					Run: func(ctx *operator.CommandContext) (string, error) {
						if err := ctx.Flags.Parse(ctx.Args); err != nil {
							return "", err
						}
						conn, err := ctx.GetConn()
						if err != nil {
							return "", err
						}
						defer conn.Close()
						client := breadpb.NewDeployClient(conn)
						resp, err := client.ListTargets(
							context.Background(),
							&breadpb.ListTargetsRequest{
								Request: ctx.Request,
							},
						)
						if err != nil {
							return "", err
						}
						return resp.Message, nil
					},
				},
				{
					Name:     "list-builds",
					Synopsis: `List the ten most recent builds for a given target`,
					Flags: []*flag.Flag{
						{
							Name:  "target",
							Usage: "Undocumented.",
						},
						{
							Name:  "branch",
							Usage: "Undocumented.",
						},
					},
					Run: func(ctx *operator.CommandContext) (string, error) {
						target := ctx.Flags.String("target", "", "")
						branch := ctx.Flags.String("branch", "", "")
						if err := ctx.Flags.Parse(ctx.Args); err != nil {
							return "", err
						}
						conn, err := ctx.GetConn()
						if err != nil {
							return "", err
						}
						defer conn.Close()
						client := breadpb.NewDeployClient(conn)
						resp, err := client.ListBuilds(
							context.Background(),
							&breadpb.ListBuildsRequest{
								Request: ctx.Request,
								Target:  *target,
								Branch:  *branch,
							},
						)
						if err != nil {
							return "", err
						}
						return resp.Message, nil
					},
				},
				{
					Name:     "trigger",
					Synopsis: `Trigger a deploy of a build to given target`,
					Flags: []*flag.Flag{
						{
							Name:  "target",
							Usage: "Undocumented.",
						},
						{
							Name:  "build",
							Usage: "Undocumented.",
						},
					},
					Run: func(ctx *operator.CommandContext) (string, error) {
						target := ctx.Flags.String("target", "", "")
						build := ctx.Flags.String("build", "", "")
						if err := ctx.Flags.Parse(ctx.Args); err != nil {
							return "", err
						}
						conn, err := ctx.GetConn()
						if err != nil {
							return "", err
						}
						defer conn.Close()
						client := breadpb.NewDeployClient(conn)
						resp, err := client.Trigger(
							context.Background(),
							&breadpb.TriggerRequest{
								Request: ctx.Request,
								Target:  *target,
								Build:   *build,
							},
						)
						if err != nil {
							return "", err
						}
						return resp.Message, nil
					},
				},
			},
		},

		{
			Name:     "ping",
			Synopsis: `Undocumented.`,
			Methods: []operator.MethodCommand{
				{
					Name:     "otp",
					Synopsis: `Test OTP verification`,
					Flags:    []*flag.Flag{},
					Run: func(ctx *operator.CommandContext) (string, error) {
						if err := ctx.Flags.Parse(ctx.Args); err != nil {
							return "", err
						}
						conn, err := ctx.GetConn()
						if err != nil {
							return "", err
						}
						defer conn.Close()
						client := breadpb.NewPingClient(conn)
						resp, err := client.Otp(
							context.Background(),
							&breadpb.OtpRequest{
								Request: ctx.Request,
							},
						)
						if err != nil {
							return "", err
						}
						return resp.Message, nil
					},
				},
				{
					Name:     "ping",
					Synopsis: `Reply with PONG if everything is working`,
					Flags: []*flag.Flag{
						{
							Name:  "arg1",
							Usage: "Undocumented.",
						},
					},
					Run: func(ctx *operator.CommandContext) (string, error) {
						arg1 := ctx.Flags.String("arg1", "", "")
						if err := ctx.Flags.Parse(ctx.Args); err != nil {
							return "", err
						}
						conn, err := ctx.GetConn()
						if err != nil {
							return "", err
						}
						defer conn.Close()
						client := breadpb.NewPingClient(conn)
						resp, err := client.Ping(
							context.Background(),
							&breadpb.PingRequest{
								Request: ctx.Request,
								Arg1:    *arg1,
							},
						)
						if err != nil {
							return "", err
						}
						return resp.Message, nil
					},
				},
				{
					Name:     "slow-loris",
					Synopsis: `Trigger a slow request, for testing timeout handling`,
					Flags: []*flag.Flag{
						{
							Name:  "wait",
							Usage: "Undocumented.",
						},
					},
					Run: func(ctx *operator.CommandContext) (string, error) {
						wait := ctx.Flags.String("wait", "", "")
						if err := ctx.Flags.Parse(ctx.Args); err != nil {
							return "", err
						}
						conn, err := ctx.GetConn()
						if err != nil {
							return "", err
						}
						defer conn.Close()
						client := breadpb.NewPingClient(conn)
						resp, err := client.SlowLoris(
							context.Background(),
							&breadpb.SlowLorisRequest{
								Request: ctx.Request,
								Wait:    *wait,
							},
						)
						if err != nil {
							return "", err
						}
						return resp.Message, nil
					},
				},
				{
					Name:     "whoami",
					Synopsis: `Reply with the email of the current authenticated user`,
					Flags:    []*flag.Flag{},
					Run: func(ctx *operator.CommandContext) (string, error) {
						if err := ctx.Flags.Parse(ctx.Args); err != nil {
							return "", err
						}
						conn, err := ctx.GetConn()
						if err != nil {
							return "", err
						}
						defer conn.Close()
						client := breadpb.NewPingClient(conn)
						resp, err := client.Whoami(
							context.Background(),
							&breadpb.WhoamiRequest{
								Request: ctx.Request,
							},
						)
						if err != nil {
							return "", err
						}
						return resp.Message, nil
					},
				},
			},
		},
	},
)

func main() {
	status, output := cmd.Run(os.Args)
	if status != 0 {
		if _, err := fmt.Fprintf(os.Stderr, "%s: %s\n", program, output); err != nil {
			panic(err)
		}
	} else {
		if _, err := io.WriteString(os.Stdout, output+"\n"); err != nil {
			panic(err)
		}
	}
	os.Exit(status)
}
