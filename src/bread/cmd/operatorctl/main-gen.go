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

const programName = "operator"

var cmd = operator.NewCommand(
	programName,
	[]operator.ServiceCommand{
		{
			Name:     "ci",
			Synopsis: `Undocumented.`,
			Methods: []operator.MethodCommand{
				{
					Name:     "list-builds",
					Synopsis: `Undocumented.`,
					Flags: []*flag.Flag{
						{
							Name:  "plan",
							Usage: "Undocumented.",
						},
					},
					Run: func(ctx *operator.CommandContext) (string, error) {
						plan := ctx.Flags.String("plan", "", "")
						if err := ctx.Flags.Parse(ctx.Args); err != nil {
							return "", err
						}
						conn, err := ctx.GetConn()
						if err != nil {
							return "", err
						}
						defer conn.Close()
						client := breadpb.NewBambooClient(conn)
						resp, err := client.ListBuilds(
							context.Background(),
							&breadpb.ListBuildsRequest{
								Request: ctx.Request,
								Plan:    *plan,
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
			Name:     "deploy",
			Synopsis: `Undocumented.`,
			Methods: []operator.MethodCommand{
				{
					Name:     "list-apps",
					Synopsis: `Undocumented.`,
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
						resp, err := client.ListApps(
							context.Background(),
							&breadpb.ListAppsRequest{
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
					Name:     "trigger",
					Synopsis: `Undocumented.`,
					Flags: []*flag.Flag{
						{
							Name:  "app",
							Usage: "Undocumented.",
						},
						{
							Name:  "build",
							Usage: "Undocumented.",
						},
					},
					Run: func(ctx *operator.CommandContext) (string, error) {
						app := ctx.Flags.String("app", "", "")
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
								App:     *app,
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
					Synopsis: `Undocumented.`,
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
						client := breadpb.NewPingerClient(conn)
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
					Synopsis: `Undocumented.`,
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
						client := breadpb.NewPingerClient(conn)
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
					Name:     "whoami",
					Synopsis: `Undocumented.`,
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
						client := breadpb.NewPingerClient(conn)
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
		if _, err := fmt.Fprintf(os.Stderr, "%s: %s\n", programName, output); err != nil {
			panic(err)
		}
	} else {
		if _, err := io.WriteString(os.Stdout, output+"\n"); err != nil {
			panic(err)
		}
	}
	os.Exit(status)
}
