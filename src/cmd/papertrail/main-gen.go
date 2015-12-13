package main

import (
	flag "flag"
	fmt "fmt"
	os "os"

	operator "github.com/sr/operator/src/operator"
	service "github.com/sr/operator/src/services/papertrail"
	env "go.pedge.io/env"
	context "golang.org/x/net/context"
	grpc "google.golang.org/grpc"
)

const commandName = "papertrail"

type mainEnv struct {
	Address string `env:"OPERATORD_ADDRESS,default=localhost:3000"`
}

type serviceCommand struct {
	client service.PapertrailServiceClient
}

func newServiceCommand(client service.PapertrailServiceClient) *serviceCommand {
	return &serviceCommand{client}
}

func (s *serviceCommand) Search() (*operator.Output, error) {
	flags := flag.NewFlagSet("search", flag.ExitOnError)

	query := flags.String("query", "", "")

	flags.Parse(os.Args[2:])
	response, err := s.client.Search(
		context.Background(),
		&service.SearchRequest{

			Query: *query,
		},
	)
	if err != nil {
		return nil, err
	}
	return response.Output, nil
}

func (s *serviceCommand) handle(method string) (*operator.Output, error) {
	switch method {

	case "search":
		return s.Search()

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
	client := service.NewPapertrailServiceClient(conn)
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
