package main

import (
	"fmt"
	"math"
	"net"

	"google.golang.org/grpc"

	"go.pedge.io/env"
	"go.pedge.io/pkg/log"
	"go.pedge.io/protoeasy"
)

type appEnv struct {
	Port   uint16 `env:"PROTOEASY_PORT,default=6789"`
	LogEnv pkglog.Env
}

func main() {
	env.Main(do, &appEnv{})
}

func do(appEnvObj interface{}) error {
	appEnv := appEnvObj.(*appEnv)
	if err := pkglog.SetupLogging("protoeasyd", appEnv.LogEnv); err != nil {
		return err
	}

	server := grpc.NewServer(grpc.MaxConcurrentStreams(math.MaxUint32))
	protoeasy.RegisterAPIServer(server, protoeasy.DefaultAPIServer)
	listener, err := net.Listen("tcp", fmt.Sprintf(":%d", appEnv.Port))
	if err != nil {
		return err
	}
	return server.Serve(listener)
}
