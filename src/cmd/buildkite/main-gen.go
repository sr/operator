package main

import (
	context "golang.org/x/net/context"
	env "go.pedge.io/env"
	flag "flag"
	fmt "fmt"
	grpc "google.golang.org/grpc"
	operator "github.com/sr/operator/src/operator"
	os "os"
	service "github.com/sr/operator/src/services/buildkite"
)

const commandName = "buildkite"

type mainEnv struct {
	Address string `env:"OPERATORD_ADDRESS,default=localhost:3000"`
}

type serviceCommand struct {
	client service.BuildkiteServiceClient
}

func newServiceCommand(client service.BuildkiteServiceClient) *serviceCommand {
	return &serviceCommand{client}
}

func (s *serviceCommand) ProjectsStatus() (*operator.Output, error) {
	flags := flag.NewFlagSet("projects-status", flag.ExitOnError)

	flags.Parse(os.Args[2:])
	response, err := s.client.ProjectsStatus(
		context.Background(),
		&service.ProjectsStatusRequest{

		},
	)
	if err != nil {
		return nil, err
	}
	return response.Output, nil
}

func (s *serviceCommand) handle(method string) (*operator.Output, error) {
	switch method {

	case "projects_status":
		return s.ProjectsStatus()

	default:
		return nil, fmt.Errorf("unspported method: %s", method)
	}
}

func main() {
	mainEnv := &mainEnv{}
	if err := env.Populate(mainEnv); err != nil {
		panic(err)
	}
	conn, err := grpc.Dial(mainEnv.Address, grpc.WithInsecure())
	if err != nil {
		panic(err)
	}
	defer conn.Close()
	if len(os.Args) < 2 {
		fmt.Fprintf(os.Stderr, "Usage: %s <method> \n", commandName)
		os.Exit(1)
	}
	client := service.NewBuildkiteServiceClient(conn)
	service := newServiceCommand(client)
	method := os.Args[1]
	output, err := service.handle(method)
	if err != nil {
		fmt.Fprintf(os.Stderr, "%v\n", err)
		os.Exit(1)
	}
	fmt.Fprintln(os.Stdout, output.PlainText)
}