package buildkite

import "github.com/buildkite/go-buildkite/buildkite"

type Env struct {
	BuildkiteAPIToken string `env:"BUILDKITE_API_TOKEN,required"`
}

func NewAPIServer(env *Env) (BuildkiteServiceServer, error) {
	config, err := buildkite.NewTokenConfig(env.BuildkiteAPIToken, false)
	if err != nil {
		return nil, err
	}
	return newAPIServer(buildkite.NewClient(config.Client())), nil
}
