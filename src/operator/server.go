package operator

import (
	"net"

	"go.pedge.io/protolog"

	"google.golang.org/grpc"
)

const defaultProtocol = "tcp"

type server struct {
	protocol  string
	address   string
	rpcServer *grpc.Server
	logger    protolog.Logger
}

func newServer(address string, logger protolog.Logger) *server {
	return &server{
		defaultProtocol,
		address,
		grpc.NewServer(),
		logger,
	}
}

func (s *server) Serve() error {
	listener, err := net.Listen(s.protocol, s.address)
	if err != nil {
		return err
	}
	s.logger.Info(&ServerStartupNotice{Address: s.address, Protocol: s.protocol})
	return s.rpcServer.Serve(listener)
}

func (s *server) Server() *grpc.Server {
	return s.rpcServer
}
