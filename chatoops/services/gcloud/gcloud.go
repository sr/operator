package gcloud

import (
	"encoding/base64"
	"fmt"

	"golang.org/x/net/context"
	"golang.org/x/oauth2/google"
	compute "google.golang.org/api/compute/v1"
)

func NewAPIServer(config *GcloudServiceConfig) (GcloudServiceServer, error) {
	s, err := base64.StdEncoding.DecodeString(config.StartupScript)
	if err != nil {
		return nil, fmt.Errorf("could not decode base64 encoded startup script: %v", err)
	}
	client, err := google.DefaultClient(context.Background())
	if err != nil {
		return nil, err
	}
	computeService, err := compute.New(client)
	if err != nil {
		return nil, err
	}
	return newAPIServer(config, client, computeService, string(s)), nil
}
