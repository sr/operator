package main

import (
	"fmt"
	"math"
	"net"

	"google.golang.org/grpc"

	"github.com/sr/operator/protoeasy"
	"go.pedge.io/env"
)

type appEnv struct {
	Port uint16 `env:"PROTOEASY_PORT,default=6789"`
}

func main() {
	env.Main(do, &appEnv{})
}

func do(appEnvObj interface{}) error {
	appEnv := appEnvObj.(*appEnv)
	server := grpc.NewServer(grpc.MaxConcurrentStreams(math.MaxUint32))
	protoeasy.RegisterAPIServer(server, protoeasy.DefaultAPIServer)
	listener, err := net.Listen("tcp", fmt.Sprintf(":%d", appEnv.Port))
	if err != nil {
		return err
	}
	return server.Serve(listener)
}
