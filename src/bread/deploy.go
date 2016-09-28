package bread

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"io/ioutil"
	"net/http"
	"net/url"
	"strings"
	"time"

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

func (s *deployAPIServer) ListTargets(ctx context.Context, req *breadpb.ListTargetsRequest) (*operator.Response, error) {
	targets := make([]string, len(s.conf.Targets))
	i := 0
	for k, _ := range s.conf.Targets {
		targets[i] = k
		i = i + 1
	}
	return operator.Reply(s, ctx, req, &operator.Message{
		Text: "Deploy targets: " + strings.Join(targets, ", "),
	})
}

func (s *deployAPIServer) ListBuilds(ctx context.Context, req *breadpb.ListBuildsRequest) (*operator.Response, error) {
	t, ok := s.conf.Targets[req.Target]
	if !ok {
		return nil, fmt.Errorf("No such deploy target: %s", req.Target)
	}
	conds := []string{
		`{"name":{"$eq":"manifest.json"}}`,
		fmt.Sprintf(`{"repo": {"$eq": "%s"}}`, s.conf.ArtifactoryRepo),
		fmt.Sprintf(`{"path": {"$match": "%s/*"}}`, t.Image),
	}
	q := []string{
		fmt.Sprintf(`items.find({"$and": [%s]})`, strings.Join(conds, ",")),
		`.include("repo","path","name","created")`,
		`.sort({"$desc": ["created"]})`,
		`.limit(10)`,
	}
	artifs, err := s.doAQL(strings.Join(q, ""))
	if err != nil {
		return nil, err
	}
	var out bytes.Buffer
	for _, a := range artifs {
		fmt.Fprintf(&out, "%s %s %s %s\n", req.Target, a.Repo, a.Path, a.Created)
	}
	return operator.Reply(s, ctx, req, &operator.Message{Text: out.String()})
}

func (s *deployAPIServer) Trigger(ctx context.Context, in *breadpb.TriggerRequest) (*operator.Response, error) {
	var cluster string
	_, ok := s.conf.Targets[in.Target]
	if !ok {
		return nil, fmt.Errorf("No such deploy target: %s", in.Target)
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
		Text: fmt.Sprintf("deployed %s to %s", in.Target, in.Build),
		Options: &operatorhipchat.MessageOptions{
			Color: "yellow",
		},
	})
}

type artifact struct {
	Path    string
	Repo    string
	Created time.Time
}

func (a *artifact) Image() string {
	if a == nil {
		return ""
	}
	return ""
}

func (a *artifact) Tag() string {
	if a == nil {
		return ""
	}
	return ""
}

func (s *deployAPIServer) doAQL(q string) ([]*artifact, error) {
	client := http.Client{}
	req, err := http.NewRequest(
		"POST",
		s.conf.ArtifactoryURL+"/api/search/aql",
		strings.NewReader(q),
	)
	if err != nil {
		return nil, err
	}
	req.Header.Set("Content-Type", "text/plain")
	req.SetBasicAuth(s.conf.ArtifactoryUsername, s.conf.ArtifactoryAPIKey)
	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		if body, err := ioutil.ReadAll(resp.Body); err == nil {
			return nil, fmt.Errorf("Artifactory query failed with status %d and body: %s", resp.StatusCode, body)
		}
		return nil, fmt.Errorf("Artifactory query failed with status %d", resp.StatusCode)
	}
	type results struct {
		Results []*artifact
	}
	var data results
	if err := json.NewDecoder(resp.Body).Decode(&data); err != nil {
		return nil, err
	}
	return data.Results, nil
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
