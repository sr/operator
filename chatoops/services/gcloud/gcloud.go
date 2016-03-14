package gcloud

import (
	"golang.org/x/net/context"
	"golang.org/x/oauth2/google"
	compute "google.golang.org/api/compute/v1"
	container "google.golang.org/api/container/v1"
)

type Env struct {
	ProjectID      string `env:"GCLOUD_PROJECT_ID,required"`
	DefaultZone    string `env:"GCLOUD_DEFAULT_ZONE,required"`
	DefaultNetwork string `env:"GCLOUD_DEFAULT_NETWORK,default=default"`
	// TODO(sr) Allow overriding this via request parameter
	// TODO(sr) Provider map (e.g. small = n1-standard, large = n2-standard, ...)
	DefaultMachineType  string `env:"GCLOUD_DEFAULT_MACHINE_TYPE,required"`
	ServiceAccountEmail string `env:"GCLOUD_SERVICE_ACCOUNT_EMAIL,required"`
}

func NewAPIServer(env *Env) (GcloudServiceServer, error) {
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
	return newAPIServer(env, client, computeService, containerService), nil
}
