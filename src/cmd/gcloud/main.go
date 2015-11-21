package main

import (
	"fmt"
	"log"

	"golang.org/x/net/context"

	"github.com/sr/operator/src/gcloud"

	"google.golang.org/grpc"
)

func main() {
	conn, err := grpc.Dial(":3000", grpc.WithInsecure())
	if err != nil {
		log.Fatal(err)
	}
	defer conn.Close()
	client := gcloud.NewGCloudServiceClient(conn)
	response, err := client.ListInstances(
		context.Background(),
		&gcloud.ListInstancesRequest{
			ProjectId: "dev-europe-west1",
		},
	)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(response)

	o, err := client.ListOperations(
		context.Background(),
		&gcloud.ListOperationsRequest{
			ProjectId: "dev-europe-west1",
		},
	)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(o)
}
