package buildkite

import "github.com/buildkite/go-buildkite/buildkite"

func NewAPIServer(config *BuildkiteServiceConfig) (BuildkiteServiceServer, error) {
	c, err := buildkite.NewTokenConfig(config.ApiToken, false)
	if err != nil {
		return nil, err
	}
	return newAPIServer(buildkite.NewClient(c.Client())), nil
}
