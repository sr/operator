package main

import (
	"fmt"
	"log"
	"os"

	"github.com/sr/operator/src/gcloud"
	"github.com/sr/operator/src/papertrail"
	"golang.org/x/net/context"
	"google.golang.org/grpc"
)

func main() {
	conn, err := grpc.Dial(":3000", grpc.WithInsecure())
	if err != nil {
		log.Fatal(err)
	}
	defer conn.Close()

	if len(os.Args) != 2 {
		fmt.Fprintf(os.Stderr, "Usage: shell <service> \n")
		os.Exit(1)
	}

	service := os.Args[1]
	switch service {
	case "gcloud":
		gcloudClient := gcloud.NewGCloudServiceClient(conn)
		gcloudListInstancesResponse, err := gcloudClient.ListInstances(
			context.Background(),
			&gcloud.ListInstancesRequest{
				ProjectId: "dev-europe-west1",
			},
		)
		if err != nil {
			log.Fatal(err)
		}
		for _, instance := range gcloudListInstancesResponse.Instances {
			fmt.Printf("%s %s %s\n", instance.Name, instance.Status, instance.Zone)
		}

		gcloudListOperationsResponse, err := gcloudClient.ListOperations(
			context.Background(),
			&gcloud.ListOperationsRequest{
				ProjectId: "dev-europe-west1",
			},
		)
		if err != nil {
			log.Fatal(err)
		}
		for _, operation := range gcloudListOperationsResponse.Operations {
			fmt.Printf("%s %s %s\n", operation.Id, operation.Type, operation.Status)
		}
	case "logs":
		papertrailClient := papertrail.NewPapertrailServiceClient(conn)
		response, err := papertrailClient.Search(
			context.Background(),
			&papertrail.SearchRequest{
				Query: "ssh",
			},
		)
		if err != nil {
			log.Fatal(err)
		}
		for _, event := range response.LogEvents {
			fmt.Println(event.LogMessage)
		}
	default:
		fmt.Fprintf(os.Stderr, "no such service: %s\n", "error")
		os.Exit(1)
	}
}
