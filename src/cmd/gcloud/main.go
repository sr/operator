package main

import (
	"flag"
	"fmt"
	"log"
	"os"

	"github.com/sr/operator/src/gcloud"
	"github.com/sr/operator/src/proto"
	"golang.org/x/net/context"
	"google.golang.org/grpc"
)

const commandName = "gcloud"

type serviceCommand struct {
	client gcloud.GCloudServiceClient
}

func newServiceCommand(client gcloud.GCloudServiceClient) *serviceCommand {
	return &serviceCommand{client}
}

func (s *serviceCommand) ListInstances() (*proto.Output, error) {
	flags := flag.NewFlagSet("list-instances", flag.ExitOnError)
	projectId := flags.String("project-id", "", "")
	flags.Parse(os.Args[2:])
	fmt.Println(*projectId)

	response, err := s.client.ListInstances(
		context.Background(),
		&gcloud.ListInstancesRequest{
			ProjectId: *projectId,
		},
	)
	if err != nil {
		return nil, err
	}
	return response.Output, nil
}

func (s *serviceCommand) handle(method string) (*proto.Output, error) {
	switch method {
	case "list-instances":
		return s.ListInstances()
	default:
		return nil, fmt.Errorf("unsupported method: %s", method)
	}
}

func main() {
	conn, err := grpc.Dial(":3000", grpc.WithInsecure())
	if err != nil {
		log.Fatal(err)
	}
	defer conn.Close()

	if len(os.Args) < 2 {
		fmt.Fprintf(os.Stderr, "Usage: %s <service> \n", commandName)
		os.Exit(1)
	}

	client := gcloud.NewGCloudServiceClient(conn)
	service := newServiceCommand(client)
	method := os.Args[1]

	output, err := service.handle(method)
	if err != nil {
		fmt.Fprintf(os.Stderr, "%v", err)
		os.Exit(1)
	}

	fmt.Fprintln(os.Stdout, output.PlainText)
}
