package operator

import (
	"os"

	"go.pedge.io/protolog"

	"google.golang.org/grpc"
)

var Logger = protolog.NewLogger(
	protolog.NewDefaultTextWritePusher(
		protolog.NewFileFlusher(os.Stderr),
	),
	protolog.LoggerOptions{},
)

type Server interface {
	Serve() error
	Server() *grpc.Server
}

type Config struct {
	Address string `env:"PORT,default=:3000"`
}

func NewServer(address string) Server {
	return newServer(address, Logger)
}

func LogServerStartupError(err error) {
	Logger.Fatal(&ServerStartupError{err.Error()})
}

func LogServiceStartupError(serviceName string, err error) {
	Logger.Error(&ServiceStartupError{
		Service: &Service{
			Name: serviceName,
		},
		Message: err.Error(),
	})
}
