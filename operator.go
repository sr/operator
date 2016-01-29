package operator

import (
	"github.com/golang/protobuf/proto"
	"github.com/sr/grpcinstrument"
	"github.com/sr/grpcinstrument/promeasurer"
	"go.pedge.io/env"
	"google.golang.org/grpc"
)

type Logger interface {
	Init() error
	Log(*grpcinstrument.Call)
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

func NewConfigFromEnv() (*Config, error) {
	config := &Config{}
	if err := env.Populate(config); err != nil {
		return nil, err
	}
	return config, nil
}

func NewServer(
	server *grpc.Server,
	config *Config,
	logger Logger,
	instrumentator grpcinstrument.Instrumentator,
) Server {
	return newServer(
		server,
		config,
		logger,
		instrumentator,
	)
}

func NewLogger() Logger {
	return newLogger()
}

func NewInstrumentator(logger Logger) grpcinstrument.Instrumentator {
	return grpcinstrument.NewLoggerMeasurer(
		logger,
		promeasurer.NewMeasurer(),
	)
}

func NewArgumentRequiredError(argument string) error {
	return &argumentRequiredError{argument}
}
