package operator

import (
	"net"

	"google.golang.org/grpc"
)

const protocol = "tcp"

type server struct {
	server       *grpc.Server
	config       *Config
	logger       Logger
	instrumenter Instrumenter
}

func newServer(
	grpcServer *grpc.Server,
	config *Config,
	logger Logger,
	instrumenter Instrumenter,
) *server {
	return &server{
		grpcServer,
		config,
		logger,
		instrumenter,
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

func (s *server) LogServiceRegistered(serviceName string) {
	s.logger.Info(&ServiceRegistered{&Service{Name: serviceName}})
}

func (s *server) LogServiceStartupError(serviceName string, err error) {
	s.logger.Error(&ServiceStartupError{
		Service: &Service{
			Name: serviceName,
		},
		Message: err.Error(),
	})
}
