package operator

import (
	"flag"

	"github.com/golang/protobuf/proto"
	"github.com/sr/grpcinstrument/promeasurer"
	"go.pedge.io/env"
	"google.golang.org/grpc"
)

type Instrumentor interface {
	Init() error
	Instrument(*Request)
}

type Logger interface {
	Info(proto.Message)
	Error(proto.Message)
}

type Server interface {
	LogServiceRegistered(service string)
	LogServiceStartupError(service string, err error)
	Serve() error
}

type Config struct {
	Address string `env:"PORT,default=:3000"`
}

type Command struct {
	name     string
	services []ServiceCommand
}

type ServiceCommand struct {
	Name     string
	Synopsis string
	Methods  []MethodCommand
}

type MethodCommand struct {
	Name     string
	Synopsis string
	Run      func([]string, *flag.FlagSet) (string, error)
}

func NewServer(
	server *grpc.Server,
	config *Config,
	logger Logger,
	instrumentor Instrumentor,
) Server {
	return newServer(
		server,
		config,
		logger,
		instrumentor,
	)
}

func NewCommand(name string, services []ServiceCommand) Command {
	return Command{name, services}
}

func NewLogger() Logger {
	return newLogger()
}

func NewInstrumentor(logger Logger) Instrumentor {
	return newInstrumentor(
		logger,
		promeasurer.NewMeasurer(),
	)
}

func NewConfigFromEnv() (*Config, error) {
	config := &Config{}
	if err := env.Populate(config); err != nil {
		return nil, err
	}
	return config, nil
}

func NewArgumentRequiredError(argument string) error {
	return &argumentRequiredError{argument}
}
