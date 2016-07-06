package breaddeploy

import (
	"strconv"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ecr"
	"github.com/aws/aws-sdk-go/service/ecs"
)

func NewAPIServer(config *DeployConfig) (DeployServer, error) {
	i, err := strconv.Atoi(config.DeployTimeout)
	if err != nil {
		return nil, err
	}
	client := session.New(&aws.Config{Region: aws.String(config.AwsRegion)})
	return newAPIServer(
		ecs.New(client),
		ecr.New(client),
		map[string]string{
			"canoe":   "canoe_production",
			"hal9000": "hal9000_production",
		},
		config.CanoeEcsService,
		i,
	)
}
