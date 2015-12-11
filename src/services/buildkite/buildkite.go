package buildkite

import "github.com/wolfeidau/go-buildkite/buildkite"

type Env struct {
	BuildkiteAPIToken string `env:"BUILDKITE_API_TOKEN,required"`
}

func NewServer(env *Env) (BuildkiteServiceServer, error) {
	config, err := buildkite.NewTokenConfig(env.BuildkiteAPIToken, false)
	if err != nil {
		return nil, err
	}
	return newServer(buildkite.NewClient(config.Client())), nil
}
