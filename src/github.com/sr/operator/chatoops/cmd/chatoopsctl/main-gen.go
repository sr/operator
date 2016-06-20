// Code generated by protoc-gen-operatorcmd
package main

import (
	"flag"
	"fmt"
	"io"
	"os"

	"github.com/sr/operator"
	buildkite "github.com/sr/operator/chatoops/services/buildkite"
	papertrail "github.com/sr/operator/chatoops/services/papertrail"
	"golang.org/x/net/context"
)

const programName = "operator"

var cmd = operator.NewCommand(
	programName,
	[]operator.ServiceCommand{
		{
			Name: "buildkite",
			Synopsis: `Interact with the Buildkite.com Continuous Integration server. Retrieve the
 status of projects, setup new ones, and trigger builds.`,
			Methods: []operator.MethodCommand{
				{
					Name: "status",
					Synopsis: `List the status of all (i.e. the status of the last build) of one or
 all projects.`,
					Flags: []*flag.Flag{
						{
							Name:  "slug",
							Usage: "Undocumented.",
						},
					},
					Run: func(ctx *operator.CommandContext) (string, error) {
						slug := ctx.Flags.String("slug", "", "")
						if err := ctx.Flags.Parse(ctx.Args); err != nil {
							return "", err
						}
						conn, err := ctx.GetConn()
						if err != nil {
							return "", err
						}
						defer conn.Close()
						client := buildkite.NewBuildkiteServiceClient(conn)
						response, err := client.Status(
							context.Background(),
							&buildkite.StatusRequest{
								Source: ctx.Source,
								Slug:   *slug,
							},
						)
						if err != nil {
							return "", err
						}
						return response.Output.PlainText, nil
					},
				},
				{
					Name: "list-builds",
					Synopsis: `List the last builds of one or all projects, optionally limited to a
 project.`,
					Flags: []*flag.Flag{
						{
							Name:  "project-slug",
							Usage: "Undocumented.",
						},
					},
					Run: func(ctx *operator.CommandContext) (string, error) {
						project_slug := ctx.Flags.String("project-slug", "", "")
						if err := ctx.Flags.Parse(ctx.Args); err != nil {
							return "", err
						}
						conn, err := ctx.GetConn()
						if err != nil {
							return "", err
						}
						defer conn.Close()
						client := buildkite.NewBuildkiteServiceClient(conn)
						response, err := client.ListBuilds(
							context.Background(),
							&buildkite.ListBuildsRequest{
								Source:      ctx.Source,
								ProjectSlug: *project_slug,
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

		{
			Name:     "papertrail",
			Synopsis: `Undocumented.`,
			Methods: []operator.MethodCommand{
				{
					Name:     "search",
					Synopsis: `Undocumented.`,
					Flags: []*flag.Flag{
						{
							Name:  "query",
							Usage: "Undocumented.",
						},
					},
					Run: func(ctx *operator.CommandContext) (string, error) {
						query := ctx.Flags.String("query", "", "")
						if err := ctx.Flags.Parse(ctx.Args); err != nil {
							return "", err
						}
						conn, err := ctx.GetConn()
						if err != nil {
							return "", err
						}
						defer conn.Close()
						client := papertrail.NewPapertrailServiceClient(conn)
						response, err := client.Search(
							context.Background(),
							&papertrail.SearchRequest{
								Source: ctx.Source,
								Query:  *query,
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
