package bread

import (
	"errors"
	"fmt"
	"net/url"
	"strings"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/ecr"
	"github.com/aws/aws-sdk-go/service/ecs"
	"github.com/sr/operator"
	"github.com/sr/operator/hipchat"
	"golang.org/x/net/context"

	"bread/pb"
)

type deployAPIServer struct {
	operator.Replier
	ecs  *ecs.ECS
	ecr  *ecr.ECR
	conf *DeployConfig
}

type parsedImg struct {
	host       string
	registryID string
	repo       string
	tag        string
}

func (s *deployAPIServer) ListApps(ctx context.Context, req *breadpb.ListAppsRequest) (*operator.Response, error) {
	apps := make([]string, len(s.conf.Apps))
	i := 0
	for _, s := range s.conf.Apps {
		apps[i] = s
		i = i + 1
	}
	return operator.Reply(s, ctx, req, &operator.Message{
		Text: "Deployable apps: " + strings.Join(apps, ", "),
	})
}

func (s *deployAPIServer) Trigger(ctx context.Context, in *breadpb.TriggerRequest) (*operator.Response, error) {
	var cluster string
	cluster, ok := s.conf.Apps[in.App]
	if !ok {
		return nil, fmt.Errorf("No such app: %s", in.App)
	}
	svc, err := s.ecs.DescribeServices(
		&ecs.DescribeServicesInput{
			Services: []*string{aws.String(s.conf.CanoeECSService)},
			Cluster:  aws.String(cluster),
		},
	)
	if err != nil {
		return nil, err
	}
	if len(svc.Services) != 1 {
		return nil, errors.New("bogus response")
	}
	out, err := s.ecs.DescribeTaskDefinition(
		&ecs.DescribeTaskDefinitionInput{
			TaskDefinition: svc.Services[0].TaskDefinition,
		},
	)
	if err != nil {
		return nil, err
	}
	curImg, err := parseImage(*out.TaskDefinition.ContainerDefinitions[0].Image)
	if curImg.tag == in.Build {
		return nil, fmt.Errorf("build %s already deployed", in.Build)
	}
	if err != nil {
		return nil, err
	}
	img := fmt.Sprintf("%s/%s:%s", curImg.host, curImg.repo, in.Build)
	var nextToken *string
	found := false
OuterLoop:
	for {
		images, err := s.ecr.ListImages(
			&ecr.ListImagesInput{
				MaxResults:     aws.Int64(100),
				NextToken:      nextToken,
				RegistryId:     aws.String(curImg.registryID),
				RepositoryName: aws.String(curImg.repo),
			},
		)
		if err != nil {
			return nil, err
		}
		nextToken = images.NextToken
		if err != nil || len(images.ImageIds) == 0 {
			break OuterLoop
		}
		for _, i := range images.ImageIds {
			if i.ImageTag == nil {
				continue
			}
			if i.ImageTag != nil && *i.ImageTag == in.Build {
				found = true
				break OuterLoop
			}
		}

	}
	if !found {
		return nil, fmt.Errorf("image for build %s not found in Docker repository", in.Build)
	}
	out.TaskDefinition.ContainerDefinitions[0].Image = aws.String(img)
	task, err := s.ecs.RegisterTaskDefinition(
		&ecs.RegisterTaskDefinitionInput{
			ContainerDefinitions: out.TaskDefinition.ContainerDefinitions,
			Family:               out.TaskDefinition.Family,
			Volumes:              out.TaskDefinition.Volumes,
		},
	)
	if err != nil {
		return nil, err
	}
	_, err = s.ecs.UpdateService(
		&ecs.UpdateServiceInput{
			Cluster:        svc.Services[0].ClusterArn,
			Service:        svc.Services[0].ServiceName,
			TaskDefinition: task.TaskDefinition.TaskDefinitionArn,
		},
	)
	if err != nil {
		return nil, err
	}
	return operator.Reply(s, ctx, in, &operator.Message{
		Text: fmt.Sprintf("deployed %s to %s", in.App, in.Build),
		Options: &operatorhipchat.MessageOptions{
			Color: "yellow",
		},
	})
}

// parseImage parses a ecs.ContainerDefinition string Image.
func parseImage(img string) (*parsedImg, error) {
	u, err := url.Parse("ecr://" + img)
	if err != nil {
		return nil, err
	}
	host := strings.Split(u.Host, ".")
	path := strings.Split(u.Path, ":")
	return &parsedImg{
		host:       u.Host,
		registryID: host[0],
		repo:       path[0][1:],
		tag:        path[1],
	}, nil
}
