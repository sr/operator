package main

import (
	"fmt"
	"log"

	"golang.org/x/net/context"
	"golang.org/x/oauth2/google"
	compute "google.golang.org/api/compute/v1"
	logging "google.golang.org/api/logging/v1beta3"
	storageapi "google.golang.org/api/storage/v1"
)

const (
	loggingScope = logging.LoggingReadScope
	bucketName   = "srozet"
	projectID    = "dev-europe-west1"
)

func main() {
	client, err := google.DefaultClient(context.Background(), loggingScope)

	storage, err := storageapi.New(client)
	if err != nil {
		log.Fatal(err)
	}
	if _, err := storage.Buckets.Get(bucketName).Do(); err == nil {
		fmt.Printf("Bucket %s already exists - skipping buckets.insert call.", bucketName)
	} else {
		// Create a bucket.
		if res, err := storage.Buckets.Insert(projectID, &storageapi.Bucket{Name: bucketName}).Do(); err == nil {
			fmt.Printf("Created bucket %v at location %v\n\n", res.Name, res.SelfLink)
		} else {
			log.Fatalf("Failed creating bucket %s: %v", bucketName, err)
		}
	}
	svc, err := compute.New(client)
	if err != nil {
		log.Fatal(err)
	}
	location := &compute.UsageExportLocation{
		BucketName:       bucketName,
		ReportNamePrefix: fmt.Sprintf("usage-%s", projectID),
	}
	request := svc.Projects.SetUsageExportBucket(projectID, location)
	response, err := request.Do()
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(response)

	// _, err := logging.New(client)
	// if err != nil {
	// 	log.Fatal(err)
	// }
	// response, err := service.Projects.Logs.List("dev-europe-west1").Do()
	// if err != nil {
	// 	log.Fatal(err)
	// }
	// for _, log := range response.Logs {
	// 	fmt.Println(log.Name)
	// }
}
