package operator

import (
	"fmt"

	"google.golang.org/grpc"
)

type Server interface {
	Serve() error
	Server() *grpc.Server
}

type Config struct {
	Address string `env:"PORT,default=:3000"`
}

func NewServer(address string) Server {
	return newServer(address)
}

func ConfigurationError(serviceName string, err error) error {
	return fmt.Errorf("service=%s %s", serviceName, err)
}

func InitializationError(serviceName string, err error) error {
	return fmt.Errorf("%s error loading server. %s", serviceName, err)
}
