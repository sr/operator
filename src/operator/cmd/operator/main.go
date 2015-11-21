package main

import (
	"log"
	"net"

	"github.com/sr/operator/src/gcloud"
	"google.golang.org/grpc"
)

func main() {
	listener, err := net.Listen("tcp", ":3000")
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}
	server := grpc.NewServer()
	gcloud.RegisterGCloudServiceServer(server, gcloud.NewAPIServer())
	server.Serve(listener)
}
