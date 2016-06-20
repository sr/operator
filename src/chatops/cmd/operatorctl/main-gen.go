// Code generated by protoc-gen-operatorcmd
package main

import (
	"flag"
	"fmt"
	"io"
	"os"

	pinger "chatops/services/ping"
	"github.com/sr/operator"
	"golang.org/x/net/context"
)

const programName = "operator"

var cmd = operator.NewCommand(
	programName,
	[]operator.ServiceCommand{
		{
			Name:     "pinger",
			Synopsis: `Undocumented.`,
			Methods: []operator.MethodCommand{
				{
					Name:     "ping",
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
						client := pinger.NewPingerClient(conn)
						response, err := client.Ping(
							context.Background(),
							&pinger.PingRequest{
								Source: ctx.Source,
							},
						)
						if err != nil {
							return "", err
						}
						return response.Output.PlainText, nil
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
		if _, err := io.WriteString(os.Stdout, output); err != nil {
			panic(err)
		}
	}
	os.Exit(status)
}
