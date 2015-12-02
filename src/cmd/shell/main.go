package main

import (
	"fmt"
	"log"

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
}
