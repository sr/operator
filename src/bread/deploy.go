package bread

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"io/ioutil"
	"net/http"
	"net/url"
	"sort"
	"strconv"
	"strings"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/ecr"
	"github.com/aws/aws-sdk-go/service/ecs"
	"github.com/sr/operator"
	"github.com/sr/operator/hipchat"
	"golang.org/x/net/context"
	"golang.org/x/net/context/ctxhttp"

	"bread/pb"
)

const (
	bambooURL = "https://bamboo.dev.pardot.com"
	master    = "master"
)

type deployAPIServer struct {
	operator.Replier
	ecs  *ecs.ECS
	ecr  *ecr.ECR
	conf *DeployConfig
	http *http.Client
}

func (s *deployAPIServer) ListTargets(ctx context.Context, req *breadpb.ListTargetsRequest) (*operator.Response, error) {
	targets := make([]string, len(s.conf.Targets))
	for i, t := range s.conf.Targets {
		targets[i] = t.Name
	}
	resp, err := s.doCanoe(ctx, "GET", "/api/projects", "")
	if err != nil {
		_, _ = operator.Reply(s, ctx, req, &operator.Message{
			Text: fmt.Sprintf("Could not get list of projects from Canoe: %v", err),
			HTML: fmt.Sprintf("Could not get list of projects from Canoe: <code>%v</code>", err),
			Options: &operatorhipchat.MessageOptions{
				Color: "red",
			},
		})
	} else {
		defer func() { _ = resp.Body.Close() }()
		var projs []*canoeProject
		if err := json.NewDecoder(resp.Body).Decode(&projs); err != nil {
			return nil, err
		}
		for _, p := range projs {
			targets = append(targets, p.Name)
		}
	}
	sort.Strings(targets)
	return operator.Reply(s, ctx, req, &operator.Message{
		Text: "Deployment targets: " + strings.Join(targets, ", "),
	})
}

func (s *deployAPIServer) ListBuilds(ctx context.Context, req *breadpb.ListBuildsRequest) (*operator.Response, error) {
	var (
		msg    *operator.Message
		err    error
		target *DeployTarget
	)
	for _, t := range s.conf.Targets {
		if t.Name == req.Target {
			target = t
		}
	}
	if target != nil {
		if msg, err = s.listECSBuilds(ctx, target); err != nil {
			return nil, err
		}
	} else {
		if req.Branch == "" {
			req.Branch = master
		}
		builds, err := s.listCanoeBuilds(ctx, req.Target, req.Branch)
		if err != nil {
			return nil, err
		}
		var txt, html bytes.Buffer
		_, _ = html.WriteString("<table><tr><th>Build</th><th>Branch</th><th>Completed</th></tr>")
		for _, b := range builds[0:10] {
			fmt.Fprintf(&txt, "%d %s %v\n", b.BuildNumber, b.Branch, b.PassedCI)
			fmt.Fprintf(
				&html,
				"<tr><td>%s</td><td>%s</td><td>%s</td></tr>\n",
				fmt.Sprintf(`<a href="%s">%d</a>`, b.URL, b.BuildNumber),
				fmt.Sprintf(`<a href="%s/tree/%s">%s@%s</a>`, b.RepoURL, b.Branch, b.Branch, b.SHA[0:7]),
				b.CreatedAt,
			)
		}
		msg = &operator.Message{Text: txt.String(), HTML: html.String()}
	}
	return operator.Reply(s, ctx, req, msg)
}

var eggs = map[string]string{
	"smiley": "https://pbs.twimg.com/profile_images/2799017051/9b51b94ade9d8a509b28ee291a2dba86_400x400.png",
	"hunter": "https://hipchat.dev.pardot.com/files/1/3/IynoW4Fx0zPhtVX/Screen%20Shot%202016-09-28%20at%206.11.57%20PM.png",
}

func (s *deployAPIServer) Trigger(ctx context.Context, req *breadpb.TriggerRequest) (*operator.Response, error) {
	if v, ok := eggs[req.Target]; ok {
		return operator.Reply(s, ctx, req, &operator.Message{
			Text: v,
			Options: &operatorhipchat.MessageOptions{
				Color: "green",
			},
		})
	}
	var (
		target *DeployTarget
		msg    *operator.Message
		err    error
	)
	for _, t := range s.conf.Targets {
		if t.Name == req.Target {
			target = t
		}
		break
	}
	if target != nil {
		msg, err = s.triggerECSDeploy(ctx, req, target)
	} else {
		msg, err = s.triggerCanoeDeploy(ctx, req)
	}
	if err != nil {
		return nil, err
	}
	return operator.Reply(s, ctx, req, msg)
}

var ecsRunning = aws.String("RUNNING")

func (s *deployAPIServer) listECSBuilds(ctx context.Context, t *DeployTarget) (*operator.Message, error) {
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
	artifs, err := s.doAQL(ctx, strings.Join(q, ""))
	if err != nil {
		return nil, err
	}
	if len(artifs) == 0 {
		return nil, fmt.Errorf("No build found for %s", t.Name)
	}
	var txt bytes.Buffer
	html := bytes.NewBufferString("<ul>")
	for _, a := range artifs {
		fmt.Fprintf(html, `<li><a href="%s/browse/%s">%s</a></li>`, bambooURL, a.Tag(), a.Tag())
		fmt.Fprintf(&txt, "%s\n", a.Tag())
	}
	_, _ = html.WriteString("</ul>")
	return &operator.Message{
		Text: txt.String(),
		HTML: html.String(),
	}, nil
}

func (s *deployAPIServer) triggerECSDeploy(ctx context.Context, req *breadpb.TriggerRequest, t *DeployTarget) (*operator.Message, error) {
	svc, err := s.ecs.DescribeServices(
		&ecs.DescribeServicesInput{
			Services: []*string{aws.String(t.ECSService)},
			Cluster:  aws.String(t.ECSCluster),
		},
	)
	if err != nil {
		return nil, err
	}
	if len(svc.Services) != 1 {
		return nil, fmt.Errorf("Cluster %s has no service %s", t.ECSCluster, t.ECSService)
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
	if err != nil {
		return nil, err
	}
	img := fmt.Sprintf("%s/%s:%s", curImg.host, curImg.repo, req.Build)
	conds := []string{
		`{"name":{"$eq":"manifest.json"}}`,
		fmt.Sprintf(`{"repo": {"$eq": "%s"}}`, s.conf.ArtifactoryRepo),
		fmt.Sprintf(`{"path": {"$match": "%s/%s"}}`, t.Image, req.Build),
	}
	artifs, err := s.doAQL(ctx, fmt.Sprintf(`items.find({"$and": [%s]})`, strings.Join(conds, ",")))
	if err != nil {
		return nil, err
	}
	if len(artifs) == 0 {
		return nil, fmt.Errorf("Build not found: %s@%s", req.Target, req.Build)
	}
	out.TaskDefinition.ContainerDefinitions[0].Image = aws.String(img)
	newTask, err := s.ecs.RegisterTaskDefinition(
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
			TaskDefinition: newTask.TaskDefinition.TaskDefinitionArn,
		},
	)
	if err != nil {
		return nil, err
	}
	_, _ = operator.Reply(s, ctx, req, &operator.Message{
		Text: fmt.Sprintf("Build %s@%s deployed to service %s. Waiting for service to rollover...", req.Target, req.Build, t.ECSService),
		Options: &operatorhipchat.MessageOptions{
			Color: "yellow",
		},
	})
	ctx, cancel := context.WithTimeout(ctx, s.conf.ECSTimeout)
	defer cancel()
	okC := make(chan struct{}, 1)
	go func() {
		for {
			lout, err := s.ecs.ListTasks(&ecs.ListTasksInput{
				Cluster:       svc.Services[0].ClusterArn,
				ServiceName:   svc.Services[0].ServiceName,
				DesiredStatus: ecsRunning,
			})
			if err != nil {
				time.Sleep(5 * time.Second)
				continue
			}
			dout, err := s.ecs.DescribeTasks(&ecs.DescribeTasksInput{
				Cluster: svc.Services[0].ClusterArn,
				Tasks:   lout.TaskArns,
			})
			if err != nil {
				time.Sleep(5 * time.Second)
				continue
			}
			for _, t := range dout.Tasks {
				if *t.TaskDefinitionArn == *newTask.TaskDefinition.TaskDefinitionArn && *t.LastStatus == *ecsRunning {
					okC <- struct{}{}
					return
				}
			}
			time.Sleep(5 * time.Second)
		}
	}()
	select {
	case <-ctx.Done():
		return nil, fmt.Errorf("Deploy of build %s@%s failed. Service did not rollover within %s", req.Target, req.Build, s.conf.ECSTimeout)
	case <-okC:
		return &operator.Message{
			Text: fmt.Sprintf("Deployed build %s@%s to %s", req.Target, req.Build, t.ECSCluster),
			Options: &operatorhipchat.MessageOptions{
				Color: "green",
			},
		}, nil
	}
}

type canoeBuild struct {
	ArtifactURL string    `json:"artifact_url"`
	RepoURL     string    `json:"repo_url"`
	URL         string    `json:"url"`
	Branch      string    `json:"branch"`
	BuildNumber int       `json:"build_number"`
	SHA         string    `json:"sha"`
	PassedCI    bool      `json:"passed_ci"`
	CreatedAt   time.Time `json:"created_at"`
}

type canoeProject struct {
	Name string `json:"name"`
}

func (s *deployAPIServer) listCanoeBuilds(ctx context.Context, proj string, branch string) ([]*canoeBuild, error) {
	resp, err := s.doCanoe(
		ctx,
		"GET",
		fmt.Sprintf("/api/projects/%s/branches/%s/builds", proj, branch),
		"",
	)
	defer func() { _ = resp.Body.Close() }()
	if err != nil {
		return nil, err
	}
	var data []*canoeBuild
	if err := json.NewDecoder(resp.Body).Decode(&data); err != nil {
		return nil, err
	}
	return data, nil
}

func (s *deployAPIServer) triggerCanoeDeploy(ctx context.Context, req *breadpb.TriggerRequest) (*operator.Message, error) {
	// https://artifactory.dev.pardot.com/artifactory/api/storage/pd-canoe/BREAD/BREAD/BREAD-EX-494.tar.gz
	buildID, err := strconv.Atoi(req.Build)
	if err != nil {
		return nil, err
	}
	var build *canoeBuild
	builds, err := s.listCanoeBuilds(ctx, req.Target, master)
	if err != nil {
		return nil, err
	}
	for _, b := range builds {
		if b.BuildNumber == buildID {
			build = b
			break
		}
	}
	if build == nil {
		return nil, fmt.Errorf("Build not found: %d", buildID)
	}
	params := url.Values{}
	params.Add("project_name", req.Target)
	params.Add("artifact_url", build.ArtifactURL)
	params.Add("user_email", req.Request.UserEmail())
	resp, err := s.doCanoe(
		ctx,
		"POST",
		"/api/targets/production/deploys",
		params.Encode(),
	)
	if err != nil {
		return nil, err
	}
	defer func() { _ = resp.Body.Close() }()
	type canoeDeploy struct {
		ID int `json:"id"`
	}
	type canoeResp struct {
		Error   bool         `json:"error"`
		Message string       `json:"message"`
		Deploy  *canoeDeploy `json:"deploy"`
	}
	var data canoeResp
	if err := json.NewDecoder(resp.Body).Decode(&data); err != nil {
		return nil, err
	}
	if data.Error {
		return nil, errors.New(data.Message)
	}
	deployURL := fmt.Sprintf("%s/projects/%s/deploys/%d?watching=1", s.conf.CanoeURL, req.Target, data.Deploy.ID)
	return &operator.Message{
		Text: deployURL,
		HTML: fmt.Sprintf(`<a href="%s">Watch %s deploy #%d</a>`, deployURL, req.Target, data.Deploy.ID),
	}, nil
}

func (s *deployAPIServer) doCanoe(ctx context.Context, meth, path, body string) (*http.Response, error) {
	req, err := http.NewRequest(meth, s.conf.CanoeURL+path, strings.NewReader(body))
	if err != nil {
		return nil, err
	}
	req.Header.Set("X-Api-Token", s.conf.CanoeAPIKey)
	if body != "" {
		req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	}
	resp, err := ctxhttp.Do(ctx, s.http, req)
	if err != nil {
		return nil, err
	}
	defer func() { _ = resp.Body.Close() }()
	if resp.StatusCode != http.StatusOK {
		if body, err := ioutil.ReadAll(resp.Body); err == nil {
			return nil, fmt.Errorf("canoe API request failed with status %d and body: %s", resp.StatusCode, body)
		}
		return nil, fmt.Errorf("canoe API request failed with status %d", resp.StatusCode)
	}
	return resp, nil
}

type artifact struct {
	Path    string
	Repo    string
	Created time.Time
}

func (a *artifact) Tag() string {
	if a == nil {
		return ""
	}
	// build/bread/hal9000/app/BREAD-BREAD-480
	parts := strings.Split(a.Path, "/")
	if len(parts) != 5 {
		return ""
	}
	return parts[4]
}

func (s *deployAPIServer) doAQL(ctx context.Context, q string) ([]*artifact, error) {
	client := &http.Client{Timeout: 10 * time.Second}
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
	resp, err := ctxhttp.Do(ctx, client, req)
	if err != nil {
		return nil, err
	}
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

type parsedImg struct {
	host       string
	registryID string
	repo       string
	tag        string
}

// parseImage parses a ecs.ContainerDefinition string Image.
func parseImage(img string) (*parsedImg, error) {
	u, err := url.Parse("docker://" + img)
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
