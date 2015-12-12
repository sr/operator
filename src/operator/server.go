package operator

import (
	"net"

	"google.golang.org/grpc"
)

const defaultProtocol = "tcp"

type server struct {
	protocol  string
	address   string
	rpcServer *grpc.Server
}

func newServer(address string) *server {
	return &server{
		defaultProtocol,
		address,
		grpc.NewServer(),
	}
}

func (s *server) Serve() error {
	listener, err := net.Listen(s.protocol, s.address)
	if err != nil {
		return err
	}
	return s.rpcServer.Serve(listener)
}

func (s *server) Server() *grpc.Server {
	return s.rpcServer
}
