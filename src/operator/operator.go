package operator

import (
	"github.com/golang/protobuf/proto"
	"github.com/rcrowley/go-metrics"
	"github.com/sr/operator/src/grpcinstrument"
	"go.pedge.io/env"
	"google.golang.org/grpc"
)

type Server interface {
	LogServiceStartupError(service string, err error)
	Serve() error
}

type Logger interface {
	Info(proto.Message)
	Error(proto.Message)
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
	return newInstrumentator(logger)
}

func NewMetricsRegistry() metrics.Registry {
	return metrics.NewRegistry()
}
