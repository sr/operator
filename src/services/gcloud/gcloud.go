package gcloud

import (
	"golang.org/x/net/context"
	"golang.org/x/oauth2/google"
)

func NewAPIServer() GCloudServiceServer {
	client, err := google.DefaultClient(context.Background())
	if err != nil {
		return nil
	}
	return newAPIServer(client)
}
