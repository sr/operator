package main

import (
	"fmt"
	"log"

	"golang.org/x/net/context"
	"golang.org/x/oauth2/google"
	logging "google.golang.org/api/logging/v1beta3"
)

const loggingScope = logging.LoggingReadScope

func main() {
	client, err := google.DefaultClient(context.Background(), loggingScope)
	service, err := logging.New(client)
	if err != nil {
		log.Fatal(err)
	}
	response, err := service.Projects.Logs.List("dev-europe-west1").Do()
	if err != nil {
		log.Fatal(err)
	}
	for _, log := range response.Logs {
		fmt.Println(log.Name)
	}
}
