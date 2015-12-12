package gcloud

import (
	"golang.org/x/net/context"
	"golang.org/x/oauth2/google"
	"google.golang.org/api/compute/v1"
	"google.golang.org/api/container/v1"
)

type Env struct{}

func NewAPIServer(env *Env) (GCloudServiceServer, error) {
	client, err := google.DefaultClient(context.Background())
	if err != nil {
		return nil, nil
	}
	computeService, err := compute.New(client)
	if err != nil {
		return nil, nil
	}
	containerService, err := container.New(client)
	if err != nil {
		return nil, nil
	}
	return newAPIServer(client, computeService, containerService), nil
}
