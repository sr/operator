package operator

import (
	"net"

	"github.com/sr/operator/src/gcloud"
	"google.golang.org/grpc"
)

func Listen() error {
	listener, err := net.Listen("tcp", ":3000")
	if err != nil {
		return err
	}
	server := grpc.NewServer()
	gcloud.RegisterGCloudServiceServer(server, gcloud.NewAPIServer())
	return server.Serve(listener)
}
