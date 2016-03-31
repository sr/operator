// Code generated by protoc-gen-operatorcmd
package main

import (
	"fmt"
	"io"
	"os"

	"github.com/sr/operator"
	buildkite "github.com/sr/operator/chatoops/services/buildkite"
	gcloud "github.com/sr/operator/chatoops/services/gcloud"
	papertrail "github.com/sr/operator/chatoops/services/papertrail"
	"golang.org/x/net/context"
	"google.golang.org/grpc"
)

const (
	programName = "operator"
)

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
					Run: func(ctx *operator.CommandContext) (string, error) {
						slug := ctx.Flags.String("slug", "", "")
						if err := ctx.Flags.Parse(ctx.Args); err != nil {
							return "", err
						}
						conn, err := dial(ctx.Address)
						if err != nil {
							return "", err
						}
						defer func() { _ = conn.Close() }()
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
					Run: func(ctx *operator.CommandContext) (string, error) {
						project_slug := ctx.Flags.String("project-slug", "", "")
						if err := ctx.Flags.Parse(ctx.Args); err != nil {
							return "", err
						}
						conn, err := dial(ctx.Address)
						if err != nil {
							return "", err
						}
						defer func() { _ = conn.Close() }()
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
			Name:     "gcloud",
			Synopsis: `Undocumented.`,
			Methods: []operator.MethodCommand{
				{
					Name:     "create-dev-instance",
					Synopsis: `Provision a development instance using the configured image.`,
					Run: func(ctx *operator.CommandContext) (string, error) {
						if err := ctx.Flags.Parse(ctx.Args); err != nil {
							return "", err
						}
						conn, err := dial(ctx.Address)
						if err != nil {
							return "", err
						}
						defer func() { _ = conn.Close() }()
						client := gcloud.NewGcloudServiceClient(conn)
						response, err := client.CreateDevInstance(
							context.Background(),
							&gcloud.CreateDevInstanceRequest{
								Source: ctx.Source,
							},
						)
						if err != nil {
							return "", err
						}
						return response.Output.PlainText, nil
					},
				},
				{
					Name:     "list-instances",
					Synopsis: `List all instances under the configured project.`,
					Run: func(ctx *operator.CommandContext) (string, error) {
						project_id := ctx.Flags.String("project-id", "", "")
						if err := ctx.Flags.Parse(ctx.Args); err != nil {
							return "", err
						}
						conn, err := dial(ctx.Address)
						if err != nil {
							return "", err
						}
						defer func() { _ = conn.Close() }()
						client := gcloud.NewGcloudServiceClient(conn)
						response, err := client.ListInstances(
							context.Background(),
							&gcloud.ListInstancesRequest{
								Source:    ctx.Source,
								ProjectId: *project_id,
							},
						)
						if err != nil {
							return "", err
						}
						return response.Output.PlainText, nil
					},
				},
				{
					Name:     "stop",
					Synopsis: `Stop a running instance.`,
					Run: func(ctx *operator.CommandContext) (string, error) {
						instance := ctx.Flags.String("instance", "", "")
						zone := ctx.Flags.String("zone", "", "")
						if err := ctx.Flags.Parse(ctx.Args); err != nil {
							return "", err
						}
						conn, err := dial(ctx.Address)
						if err != nil {
							return "", err
						}
						defer func() { _ = conn.Close() }()
						client := gcloud.NewGcloudServiceClient(conn)
						response, err := client.Stop(
							context.Background(),
							&gcloud.StopRequest{
								Source:   ctx.Source,
								Instance: *instance,
								Zone:     *zone,
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
					Run: func(ctx *operator.CommandContext) (string, error) {
						query := ctx.Flags.String("query", "", "")
						if err := ctx.Flags.Parse(ctx.Args); err != nil {
							return "", err
						}
						conn, err := dial(ctx.Address)
						if err != nil {
							return "", err
						}
						defer func() { _ = conn.Close() }()
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

func dial(address string) (*grpc.ClientConn, error) {
	conn, err := grpc.Dial(address, grpc.WithInsecure())
	if err != nil {
		return nil, err
	}
	return conn, nil
}
