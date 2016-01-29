package operator

import (
	"net"

	"go.pedge.io/protolog"

	"github.com/sr/grpcinstrument"

	"google.golang.org/grpc"

	"github.com/sr/operator/proto"
)

const protocol = "tcp"

type server struct {
	server         *grpc.Server
	config         *Config
	logger         protolog.Logger
	instrumentator grpcinstrument.Instrumentator
}

func newServer(
	grpcServer *grpc.Server,
	config *Config,
	logger protolog.Logger,
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
		s.logger.Error(&operatorproto.ServerStartupError{err.Error()})
		return err
	}
	s.logger.Info(&operatorproto.ServerStartupNotice{Address: s.config.Address, Protocol: protocol})
	err = s.server.Serve(listener)
	if err != nil {
		s.logger.Error(&operatorproto.ServerStartupError{err.Error()})
		return err
	}
	return nil
}

func (s *server) LogServiceRegistered(serviceName string) {
	s.logger.Info(&operatorproto.ServiceRegistered{&operatorproto.Service{Name: serviceName}})
}

func (s *server) LogServiceStartupError(serviceName string, err error) {
	s.logger.Error(&operatorproto.ServiceStartupError{
		Service: &operatorproto.Service{
			Name: serviceName,
		},
		Message: err.Error(),
	})
}
