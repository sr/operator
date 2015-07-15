package main

import (
	"log"
	"net"

	"github.com/sr/operator/src/services/ecs"
	"google.golang.org/grpc"
)

func main() {
	listener, err := net.Listen("tcp", ":3000")
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}
	server := grpc.NewServer()
	service_ecs.RegisterECSServiceServer(server, service_ecs.NewServer())
	server.Serve(listener)
}
