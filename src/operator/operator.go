package operator

import (
	"os"

	"github.com/sr/grpcinstrument"
	"github.com/sr/grpcinstrument/promeasurer"
	"github.com/sr/grpcinstrument/protologger"
	"go.pedge.io/env"
	"go.pedge.io/protolog"
	"google.golang.org/grpc"
)

type Server interface {
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
	logger protolog.Logger,
	instrumentator grpcinstrument.Instrumentator,
) Server {
	return newServer(
		server,
		config,
		logger,
		instrumentator,
	)
}

func NewLogger() protolog.Logger {
	return protolog.NewLogger(
		protolog.NewDefaultTextWritePusher(
			protolog.NewFileFlusher(os.Stderr),
		),
		protolog.LoggerOptions{},
	)
}

func NewInstrumentator(logger protolog.Logger) grpcinstrument.Instrumentator {
	return grpcinstrument.NewLoggerMeasurer(
		protologger.NewLogger(logger),
		promeasurer.NewMeasurer(),
	)
}

func NewArgumentRequiredError(argument string) error {
	return &argumentRequiredError{argument}
}
