package main

import (
	flag "flag"
	fmt "fmt"
	os "os"

	operator "github.com/sr/operator/src/operator"
	service "github.com/sr/operator/src/services/gcloud"
	env "go.pedge.io/env"
	context "golang.org/x/net/context"
	grpc "google.golang.org/grpc"
)

const commandName = "gcloud"

type mainEnv struct {
	Address string `env:"OPERATORD_ADDRESS,default=localhost:3000"`
}

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

	case "create-container-cluster":
		return s.CreateContainerCluster()

	case "list-instances":
		return s.ListInstances()

	default:
		return nil, fmt.Errorf("unspported method: %s", method)
	}
}

func run() error {
	mainEnv := &mainEnv{}
	if err := env.Populate(mainEnv); err != nil {
		return err
	}
	conn, err := grpc.Dial(mainEnv.Address, grpc.WithInsecure())
	if err != nil {
		return err
	}
	defer conn.Close()
	if len(os.Args) < 2 {
		return fmt.Errorf("Usage: %s <method>", commandName)
	}
	client := service.NewGCloudServiceClient(conn)
	service := newServiceCommand(client)
	method := os.Args[1]
	output, err := service.handle(method)
	if err != nil {
		return err
	}
	_, err = fmt.Fprintln(os.Stdout, output.PlainText)
	return err
}

func main() {
	if err := run(); err != nil {
		fmt.Fprintf(os.Stderr, "%v\n", err)
		os.Exit(1)
	}
}
