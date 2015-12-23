package main

import (
	"golang.org/x/net/context"
	"google.golang.org/grpc"
	"flag"
	"fmt"
	"os"
	"go.pedge.io/env"

	"github.com/sr/operator/src/services/buildkite"
	"github.com/sr/operator/src/services/gcloud"
	"github.com/sr/operator/src/services/papertrail"
)

const usage = `Usage: operator <service> <command>

Use  'operator help <service>' for help with a particular service.

Available services:

  buildkite
     Interact with the Buildkite.com Continuous Integration server. Let's you
     retrieve the status of projects, setup new ones, and trigger builds.

  gcloud
    Undocumented.
  papertrail
    Undocumented.`

type mainEnv struct {
	Address string `env:"OPERATORD_ADDRESS,default=localhost:3000"`
}

func showUsage(s string) {
	fmt.Fprintf(os.Stderr, "%s\n", s)
	os.Exit(2)
}

func fatal(message string) {
	fmt.Fprintf(os.Stderr, "operator: %s\n", message)
	os.Exit(1)
}

func main() {
	mainEnv := &mainEnv{}
	if err := env.Populate(mainEnv); err != nil {
		fatal(err.Error())
	}
	if len(os.Args) == 1 || os.Args[1] == "-h" || os.Args[1] == "--help" ||
		os.Args[1] == "help" {
		showUsage(usage)
	}
	if len(os.Args) >= 2 {
		service := os.Args[1]
		switch service {
		case "buildkite":
			if (len(os.Args) == 2 || (os.Args[2] == "-h" ||
				os.Args[2] == "--help" || os.Args[2] == "help")) {
				showUsage(`Usage: operator buildkite [command]

 Interact with the Buildkite.com Continuous Integration server. Let's you
 retrieve the status of projects, setup new ones, and trigger builds.

Available Commands:
  status  List the status of all (i.e. the status of the last build) of one or  all projects.
  list-builds  List the last builds of one or all projects, optionally limited to a  branch. `)
			} else {
				command := os.Args[2]
				switch command {
				case "status":
					flags := flag.NewFlagSet("status", flag.ExitOnError)
					slug := flags.String("slug", "", "")
					flags.Parse(os.Args[2:])
					conn, err := grpc.Dial(mainEnv.Address, grpc.WithInsecure())
					if err != nil {
						fatal(err.Error())
					}
					defer conn.Close()
					client := buildkite.NewBuildkiteServiceClient(conn)
					response, err := client.Status(
						context.Background(),
						&buildkite.StatusRequest{
							Slug: *slug,
						},
					)
					if err != nil {
						fatal(err.Error())
					}
					fmt.Fprintf(os.Stdout, "%s\n", response.Output.PlainText)
					os.Exit(0)
				case "list-builds":
					flags := flag.NewFlagSet("list-builds", flag.ExitOnError)
					slug := flags.String("slug", "", "")
					branch := flags.String("branch", "", "")
					flags.Parse(os.Args[2:])
					conn, err := grpc.Dial(mainEnv.Address, grpc.WithInsecure())
					if err != nil {
						fatal(err.Error())
					}
					defer conn.Close()
					client := buildkite.NewBuildkiteServiceClient(conn)
					response, err := client.ListBuilds(
						context.Background(),
						&buildkite.ListBuildsRequest{
							Slug: *slug,
							Branch: *branch,
						},
					)
					if err != nil {
						fatal(err.Error())
					}
					fmt.Fprintf(os.Stdout, "%s\n", response.Output.PlainText)
					os.Exit(0)
				default:
					fatal(fmt.Sprintf("no such command: %s", command))
				}
			}
		case "gcloud":
			if (len(os.Args) == 2 || (os.Args[2] == "-h" ||
				os.Args[2] == "--help" || os.Args[2] == "help")) {
				showUsage(`Usage: operator gcloud [command]

Undocumented.
Available Commands:
  create-container-cluster Undocumented.
  list-instances Undocumented.`)
			} else {
				command := os.Args[2]
				switch command {
				case "create-container-cluster":
					flags := flag.NewFlagSet("create-container-cluster", flag.ExitOnError)
					project_id := flags.String("project-id", "", "")
					name := flags.String("name", "", "")
					node_count := flags.String("node-count", "", "")
					zone := flags.String("zone", "", "")
					flags.Parse(os.Args[2:])
					conn, err := grpc.Dial(mainEnv.Address, grpc.WithInsecure())
					if err != nil {
						fatal(err.Error())
					}
					defer conn.Close()
					client := gcloud.NewGCloudServiceClient(conn)
					response, err := client.CreateContainerCluster(
						context.Background(),
						&gcloud.CreateContainerClusterRequest{
							ProjectId: *project_id,
							Name: *name,
							NodeCount: *node_count,
							Zone: *zone,
						},
					)
					if err != nil {
						fatal(err.Error())
					}
					fmt.Fprintf(os.Stdout, "%s\n", response.Output.PlainText)
					os.Exit(0)
				case "list-instances":
					flags := flag.NewFlagSet("list-instances", flag.ExitOnError)
					project_id := flags.String("project-id", "", "")
					flags.Parse(os.Args[2:])
					conn, err := grpc.Dial(mainEnv.Address, grpc.WithInsecure())
					if err != nil {
						fatal(err.Error())
					}
					defer conn.Close()
					client := gcloud.NewGCloudServiceClient(conn)
					response, err := client.ListInstances(
						context.Background(),
						&gcloud.ListInstancesRequest{
							ProjectId: *project_id,
						},
					)
					if err != nil {
						fatal(err.Error())
					}
					fmt.Fprintf(os.Stdout, "%s\n", response.Output.PlainText)
					os.Exit(0)
				default:
					fatal(fmt.Sprintf("no such command: %s", command))
				}
			}
		case "papertrail":
			if (len(os.Args) == 2 || (os.Args[2] == "-h" ||
				os.Args[2] == "--help" || os.Args[2] == "help")) {
				showUsage(`Usage: operator papertrail [command]

Undocumented.
Available Commands:
  search Undocumented.`)
			} else {
				command := os.Args[2]
				switch command {
				case "search":
					flags := flag.NewFlagSet("search", flag.ExitOnError)
					query := flags.String("query", "", "")
					flags.Parse(os.Args[2:])
					conn, err := grpc.Dial(mainEnv.Address, grpc.WithInsecure())
					if err != nil {
						fatal(err.Error())
					}
					defer conn.Close()
					client := papertrail.NewPapertrailServiceClient(conn)
					response, err := client.Search(
						context.Background(),
						&papertrail.SearchRequest{
							Query: *query,
						},
					)
					if err != nil {
						fatal(err.Error())
					}
					fmt.Fprintf(os.Stdout, "%s\n", response.Output.PlainText)
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