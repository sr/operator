package main

import (
	"flag"
	"fmt"
	buildkite "github.com/sr/operator/src/services/buildkite"
	gcloud "github.com/sr/operator/src/services/gcloud"
	papertrail "github.com/sr/operator/src/services/papertrail"
	"go.pedge.io/env"
	"golang.org/x/net/context"
	"google.golang.org/grpc"
	"os"
)

const (
	usage = `Usage: operator <service> <command>

Use  "operator help <service>" for help with a particular service.

Available services:

buildkite
  Interact with the Buildkite.com Continuous Integration server. Let's you
  retrieve the status of projects, setup new ones, and trigger builds.

gcloud
  Undocumented.

papertrail
  Undocumented.
`
	usageServiceBuildkite = `Usage: operator buildkite [command]

Interact with the Buildkite.com Continuous Integration server. Let's you
retrieve the status of projects, setup new ones, and trigger builds.

Available Commands:

status
 List the status of all (i.e. the status of the last build) of one or  all
 projects.

list-builds
 List the last builds of one or all projects, optionally limited to a  branch.
`
	usageServiceGcloud = `Usage: operator gcloud [command]

Undocumented.

Available Commands:

create-container-cluster
 Undocumented.

list-instances
 Undocumented.
`
	usageServicePapertrail = `Usage: operator papertrail [command]

Undocumented.

Available Commands:

search
 Undocumented.
`
)

type mainEnv struct {
	Address string `env:"OPERATORD_ADDRESS,default=localhost:3000"`
}

type client struct {
	client *grpc.ClientConn
}

func dial(address string) (*client, error) {
	conn, err := grpc.Dial(address, grpc.WithInsecure())
	if err != nil {
		return nil, err
	}
	return &client{conn}, nil
}

func (c *client) close() {
	c.client.Close()
}

func isHelp(arg string) bool {
	return arg == "-h" || arg == "--help" || arg == "help"
}

func showUsage(s string) {
	fmt.Fprintf(os.Stderr, "%s\n", s)
	os.Exit(2)
}

func fatal(message string) {
	fmt.Fprintf(os.Stderr, "operator: %s\n", message)
	os.Exit(1)
}
func (c *client) doBuildkiteStatus() (string, error) {
	flags := flag.NewFlagSet("status", flag.ExitOnError)
	slug := flags.String("slug", "", "")
	flags.Parse(os.Args[2:])
	client := buildkite.NewBuildkiteServiceClient(c.client)
	response, err := client.Status(
		context.Background(),
		&buildkite.StatusRequest{
			Slug: *slug,
		},
	)
	if err != nil {
		return "", err
	}
	return response.Output.PlainText, nil
}

func (c *client) doBuildkiteListBuilds() (string, error) {
	flags := flag.NewFlagSet("list-builds", flag.ExitOnError)
	slug := flags.String("slug", "", "")
	branch := flags.String("branch", "", "")
	flags.Parse(os.Args[2:])
	client := buildkite.NewBuildkiteServiceClient(c.client)
	response, err := client.ListBuilds(
		context.Background(),
		&buildkite.ListBuildsRequest{
			Slug:   *slug,
			Branch: *branch,
		},
	)
	if err != nil {
		return "", err
	}
	return response.Output.PlainText, nil
}

func (c *client) doGcloudCreateContainerCluster() (string, error) {
	flags := flag.NewFlagSet("create-container-cluster", flag.ExitOnError)
	project_id := flags.String("project-id", "", "")
	name := flags.String("name", "", "")
	node_count := flags.String("node-count", "", "")
	zone := flags.String("zone", "", "")
	flags.Parse(os.Args[2:])
	client := gcloud.NewGcloudServiceClient(c.client)
	response, err := client.CreateContainerCluster(
		context.Background(),
		&gcloud.CreateContainerClusterRequest{
			ProjectId: *project_id,
			Name:      *name,
			NodeCount: *node_count,
			Zone:      *zone,
		},
	)
	if err != nil {
		return "", err
	}
	return response.Output.PlainText, nil
}

func (c *client) doGcloudListInstances() (string, error) {
	flags := flag.NewFlagSet("list-instances", flag.ExitOnError)
	project_id := flags.String("project-id", "", "")
	flags.Parse(os.Args[2:])
	client := gcloud.NewGcloudServiceClient(c.client)
	response, err := client.ListInstances(
		context.Background(),
		&gcloud.ListInstancesRequest{
			ProjectId: *project_id,
		},
	)
	if err != nil {
		return "", err
	}
	return response.Output.PlainText, nil
}

func (c *client) doPapertrailSearch() (string, error) {
	flags := flag.NewFlagSet("search", flag.ExitOnError)
	query := flags.String("query", "", "")
	flags.Parse(os.Args[2:])
	client := papertrail.NewPapertrailServiceClient(c.client)
	response, err := client.Search(
		context.Background(),
		&papertrail.SearchRequest{
			Query: *query,
		},
	)
	if err != nil {
		return "", err
	}
	return response.Output.PlainText, nil
}

func main() {
	mainEnv := &mainEnv{}
	if err := env.Populate(mainEnv); err != nil {
		fatal(err.Error())
	}
	if len(os.Args) == 1 || isHelp(os.Args[1]) {
		showUsage(usage)
	}
	if len(os.Args) >= 2 {
		service := os.Args[1]
		switch service {
		case "buildkite":
			if len(os.Args) == 2 || isHelp(os.Args[2]) {
				showUsage(usageServiceBuildkite)
			} else {
				command := os.Args[2]
				switch command {
				case "status":
					client, err := dial(mainEnv.Address)
					if err != nil {
						fatal(err.Error())
					}
					defer client.close()
					output, err := client.doBuildkiteStatus()
					if err != nil {
						fatal(err.Error())
					}
					fmt.Fprintf(os.Stdout, "%s\n", output)
					os.Exit(0)
				case "list-builds":
					client, err := dial(mainEnv.Address)
					if err != nil {
						fatal(err.Error())
					}
					defer client.close()
					output, err := client.doBuildkiteListBuilds()
					if err != nil {
						fatal(err.Error())
					}
					fmt.Fprintf(os.Stdout, "%s\n", output)
					os.Exit(0)
				default:
					fatal(fmt.Sprintf("no such command: %s", command))
				}
			}
		case "gcloud":
			if len(os.Args) == 2 || isHelp(os.Args[2]) {
				showUsage(usageServiceGcloud)
			} else {
				command := os.Args[2]
				switch command {
				case "create-container-cluster":
					client, err := dial(mainEnv.Address)
					if err != nil {
						fatal(err.Error())
					}
					defer client.close()
					output, err := client.doGcloudCreateContainerCluster()
					if err != nil {
						fatal(err.Error())
					}
					fmt.Fprintf(os.Stdout, "%s\n", output)
					os.Exit(0)
				case "list-instances":
					client, err := dial(mainEnv.Address)
					if err != nil {
						fatal(err.Error())
					}
					defer client.close()
					output, err := client.doGcloudListInstances()
					if err != nil {
						fatal(err.Error())
					}
					fmt.Fprintf(os.Stdout, "%s\n", output)
					os.Exit(0)
				default:
					fatal(fmt.Sprintf("no such command: %s", command))
				}
			}
		case "papertrail":
			if len(os.Args) == 2 || isHelp(os.Args[2]) {
				showUsage(usageServicePapertrail)
			} else {
				command := os.Args[2]
				switch command {
				case "search":
					client, err := dial(mainEnv.Address)
					if err != nil {
						fatal(err.Error())
					}
					defer client.close()
					output, err := client.doPapertrailSearch()
					if err != nil {
						fatal(err.Error())
					}
					fmt.Fprintf(os.Stdout, "%s\n", output)
					os.Exit(0)
				default:
					fatal(fmt.Sprintf("no such command: %s", command))
				}
			}
		default:
			fatal(fmt.Sprintf("no such service: %s", service))
		}
	}
}
