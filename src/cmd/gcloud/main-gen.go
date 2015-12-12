package main

import (
	context "golang.org/x/net/context"
	flag "flag"
	fmt "fmt"
	grpc "google.golang.org/grpc"
	operator "github.com/sr/operator/src/operator"
	os "os"
	service "github.com/sr/operator/src/services/gcloud"
)

const commandName = "gcloud"

type serviceCommand struct {
	client service.GCloudServiceClient
}

func newServiceCommand(client service.GCloudServiceClient) *serviceCommand {
	return &serviceCommand{client}
}

func (s *serviceCommand) CreateContainerCluster() (*operator.Output, error) {
	flags := flag.NewFlagSet("create-container-cluster", flag.ExitOnError)

	projectID := flags.String("project-id", "", "")

	name := flags.String("name", "", "")

	nodeCount := flags.String("node-count", "", "")

	zone := flags.String("zone", "", "")

	flags.Parse(os.Args[2:])
	response, err := s.client.CreateContainerCluster(
		context.Background(),
		&service.CreateContainerClusterRequest{

			ProjectId: *projectID,

			Name: *name,

			NodeCount: *nodeCount,

			Zone: *zone,

		},
	)
	if err != nil {
		return nil, err
	}
	return response.Output, nil
}

func (s *serviceCommand) ListInstances() (*operator.Output, error) {
	flags := flag.NewFlagSet("list-instances", flag.ExitOnError)

	projectID := flags.String("project-id", "", "")

	flags.Parse(os.Args[2:])
	response, err := s.client.ListInstances(
		context.Background(),
		&service.ListInstancesRequest{

			ProjectId: *projectID,

		},
	)
	if err != nil {
		return nil, err
	}
	return response.Output, nil
}

func (s *serviceCommand) handle(method string) (*operator.Output, error) {
	switch method {

	case "create_container_cluster":
		return s.CreateContainerCluster()

	case "list_instances":
		return s.ListInstances()

	default:
		return nil, fmt.Errorf("unspported method: %s", method)
	}
}

func main() {
	conn, err := grpc.Dial(":3000", grpc.WithInsecure())
	if err != nil {
		panic(err)
	}
	defer conn.Close()
	if len(os.Args) < 2 {
		fmt.Fprintf(os.Stderr, "Usage: %s <method> \n", commandName)
		os.Exit(1)
	}
	client := service.NewGCloudServiceClient(conn)
	service := newServiceCommand(client)
	method := os.Args[1]
	output, err := service.handle(method)
	if err != nil {
		fmt.Fprintf(os.Stderr, "%v\n", err)
		os.Exit(1)
	}
	fmt.Fprintln(os.Stdout, output.PlainText)
}