package gcloud

import (
	"encoding/base64"
	"fmt"

	"golang.org/x/net/context"
	"golang.org/x/oauth2/google"
	compute "google.golang.org/api/compute/v1"
)

type Env struct {
	ProjectID      string `env:"GCLOUD_PROJECT_ID,required"`
	DefaultZone    string `env:"GCLOUD_DEFAULT_ZONE,required"`
	DefaultNetwork string `env:"GCLOUD_DEFAULT_NETWORK,default=default"`
	// TODO(sr) Allow listing all available custom images
	// TODO(sr) Use the most recent image by default
	// TODO(sr) Allow to override this per request
	DefaultImage string `env:"GCLOUD_DEFAULT_IMAGE,required"`
	// TODO(sr) Allow overriding this via request parameter
	// TODO(sr) Provider map (e.g. small = n1-standard, large = n2-standard, ...)
	DefaultMachineType  string `env:"GCLOUD_DEFAULT_MACHINE_TYPE,required"`
	ServiceAccountEmail string `env:"GCLOUD_SERVICE_ACCOUNT_EMAIL,required"`
	StartupScript       string `env:"GCLOUD_STARTUP_SCRIPT,required"`
}

func NewAPIServer(env *Env) (GcloudServiceServer, error) {
	s, err := base64.StdEncoding.DecodeString(env.StartupScript)
	if err != nil {
		return nil, fmt.Errorf("could not decode GCLOUD_STARTUP_SCRIPT: %v", err)
	}
	client, err := google.DefaultClient(context.Background())
	if err != nil {
		return nil, err
	}
	computeService, err := compute.New(client)
	if err != nil {
		return nil, err
	}
	return newAPIServer(env, client, computeService, string(s)), nil
}
