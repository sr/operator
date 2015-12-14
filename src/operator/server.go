package operator

import (
	"net"

	"github.com/sr/operator/src/grpcinstrument"

	"google.golang.org/grpc"
)

const protocol = "tcp"

type server struct {
	server         *grpc.Server
	config         *Config
	logger         Logger
	instrumentator grpcinstrument.Instrumentator
}

func newServer(
	grpcServer *grpc.Server,
	config *Config,
	logger Logger,
	instrumentator grpcinstrument.Instrumentator,
) *server {
	return &server{
		grpcServer,
		config,
		logger,
		instrumentator,
	}
}

func (s *server) Serve() error {
	listener, err := net.Listen(protocol, s.config.Address)
	if err != nil {
		s.logger.Error(&ServerStartupError{err.Error()})
		return err
	}
	s.logger.Info(&ServerStartupNotice{Address: s.config.Address, Protocol: protocol})
	err = s.server.Serve(listener)
	if err != nil {
		s.logger.Error(&ServerStartupError{err.Error()})
		return err
	}
	return nil
}

func (s *server) LogServiceStartupError(serviceName string, err error) {
	s.logger.Error(&ServiceStartupError{
		Service: &Service{
			Name: serviceName,
		},
		Message: err.Error(),
	})
}
