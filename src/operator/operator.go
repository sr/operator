package operator

import (
	"os"

	"go.pedge.io/protolog"

	"github.com/sr/operator/src/grpclog"
	"google.golang.org/grpc"
)

var (
	Logger     = NewLogger()
	GRPCLogger = newGRPCLogger(Logger)
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

func NewLogger() protolog.Logger {
	return protolog.NewLogger(
		protolog.NewDefaultTextWritePusher(
			protolog.NewFileFlusher(os.Stderr),
		),
		protolog.LoggerOptions{},
	)
}

func NewGRPCLogger() grpclog.Logger {
	return newGRPCLogger(Logger)
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
