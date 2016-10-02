package bread

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"sort"
	"strconv"
	"strings"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/ecs"
	"github.com/sr/operator"
	"github.com/sr/operator/hipchat"
	"golang.org/x/net/context"
	"golang.org/x/net/context/ctxhttp"

	"bread/pb"
)

type ecsDeployer struct {
	operator.Replier
	afyURL    string
	afyRepo   string
	afyUser   string
	afyAPIKey string
	ecs       *ecs.ECS
	targets   []*DeployTarget
	timeout   time.Duration
}

type afyItem struct {
	Path       string      `json:"path"`
	Repo       string      `json:"repo"`
	Created    time.Time   `json:"created"`
	Properties []*property `json:"properties"`
}

type property struct {
	Key   string `json:"key"`
	Value string `json:"value"`
}

func (d *ecsDeployer) listTargets(ctx context.Context) ([]*DeployTarget, error) {
	return d.targets, nil
}

func (d *ecsDeployer) listBuilds(ctx context.Context, t *DeployTarget, branch string) ([]build, error) {
	conds := []string{
		`{"name":{"$eq":"manifest.json"}}`,
		fmt.Sprintf(`{"repo": {"$eq": "%s"}}`, d.afyRepo),
		fmt.Sprintf(`{"path": {"$match": "%s/*"}}`, t.Image),
	}
	q := []string{
		fmt.Sprintf(`items.find({"$and": [%s]})`, strings.Join(conds, ",")),
		`.include("repo","path","name","created","property.*")`,
	}
	items, err := d.doAQL(ctx, strings.Join(q, ""))
	if err != nil {
		return nil, err
	}
	sorted := afyItems(items)
	sort.Sort(sort.Reverse(sorted))
	var builds []build
	for _, a := range sorted {
		builds = append(builds, build(a))
	}
	return builds, nil
}

func (d *ecsDeployer) deploy(ctx context.Context, req *operator.Request, t *DeployTarget, b build) (*operator.Message, error) {
	svc, err := d.ecs.DescribeServices(
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
	out, err := d.ecs.DescribeTaskDefinition(
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
	img := fmt.Sprintf("%s/%s:%s", curImg.host, curImg.repo, b.GetBambooID())
	out.TaskDefinition.ContainerDefinitions[0].Image = aws.String(img)
	newTask, err := d.ecs.RegisterTaskDefinition(
		&ecs.RegisterTaskDefinitionInput{
			ContainerDefinitions: out.TaskDefinition.ContainerDefinitions,
			Family:               out.TaskDefinition.Family,
			Volumes:              out.TaskDefinition.Volumes,
		},
	)
	if err != nil {
		return nil, err
	}
	_, err = d.ecs.UpdateService(
		&ecs.UpdateServiceInput{
			Cluster:        svc.Services[0].ClusterArn,
			Service:        svc.Services[0].ServiceName,
			TaskDefinition: newTask.TaskDefinition.TaskDefinitionArn,
		},
	)
	if err != nil {
		return nil, err
	}
	var (
		html    string
		fingers = `<img class="remoticon" aria-label="(fingerscrossed)" alt="(fingerscrossed)" height="30" width="30" src="https://hipchat.dev.pardot.com/files/img/emoticons/1/fingerscrossed-1459185721@2x.png">`
	)
	if t.Name == "operator" {
		html = fmt.Sprintf(
			"Updated <code>%s@%s</code> to run build %d. Restarting... should be back soon %s",
			*svc.Services[0].ServiceName,
			t.ECSCluster,
			b.GetNumber(),
			fingers,
		)
	} else {
		html = fmt.Sprintf(
			"Updated ECS service <code>%s@%s</code> to run build %s. Waiting up to %s for service to rollover...",
			*svc.Services[0].ServiceName,
			t.ECSCluster,
			fmt.Sprintf(`<a href="%s/browse/%s">%s</a>`, bambooURL, b.GetBambooID(), b.GetBambooID()),
			d.timeout,
		)
	}
	// TODO(sr) Figure out a nicer interface for sending non-final messages
	_, _ = operator.Reply(d, ctx, &breadpb.TriggerRequest{Request: req}, &operator.Message{
		Text: *newTask.TaskDefinition.TaskDefinitionArn,
		HTML: html,
		Options: &operatorhipchat.MessageOptions{
			Color: "yellow",
		},
	})
	ctx, cancel := context.WithTimeout(ctx, d.timeout)
	defer cancel()
	okC := make(chan struct{}, 1)
	go func() {
		for {
			lout, err := d.ecs.ListTasks(&ecs.ListTasksInput{
				Cluster:       svc.Services[0].ClusterArn,
				ServiceName:   svc.Services[0].ServiceName,
				DesiredStatus: ecsRunning,
			})
			if err != nil {
				time.Sleep(5 * time.Second)
				continue
			}
			dout, err := d.ecs.DescribeTasks(&ecs.DescribeTasksInput{
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
		return nil, fmt.Errorf("Deploy of build %s@%d failed. Service did not rollover within %s", t.Name, b.GetNumber(), d.timeout)
	case <-okC:
		return &operator.Message{
			Text: fmt.Sprintf("Deployed build %s@%d to %s", t.Name, b.GetNumber(), t.ECSCluster),
			HTML: fmt.Sprintf(
				"Deployed build %s to ECS service <code>%s@%s</code>",
				fmt.Sprintf(`<a href="%s/browse/%s">%s</a>`, bambooURL, b.GetBambooID(), b.GetBambooID()),
				*svc.Services[0].ServiceName,
				t.ECSCluster,
			),
			Options: &operatorhipchat.MessageOptions{
				Color: "green",
			},
		}, nil
	}
}

func (d *ecsDeployer) doAQL(ctx context.Context, q string) ([]*afyItem, error) {
	client := &http.Client{Timeout: 10 * time.Second}
	req, err := http.NewRequest(
		"POST",
		d.afyURL+"/api/search/aql",
		strings.NewReader(q),
	)
	if err != nil {
		return nil, err
	}
	req.Header.Set("Content-Type", "text/plain")
	req.SetBasicAuth(d.afyUser, d.afyAPIKey)
	resp, err := ctxhttp.Do(ctx, client, req)
	if err != nil {
		return nil, err
	}
	if resp.StatusCode != http.StatusOK {
		if body, err := ioutil.ReadAll(resp.Body); err == nil {
			return nil, fmt.Errorf("artifactory query failed with status %d and body: %s", resp.StatusCode, body)
		}
		return nil, fmt.Errorf("artifactory query failed with status %d", resp.StatusCode)
	}
	type results struct {
		Results []*afyItem
	}
	var data results
	if err := json.NewDecoder(resp.Body).Decode(&data); err != nil {
		return nil, err
	}
	return data.Results, nil
}

func (a *afyItem) GetNumber() int {
	if a == nil {
		return 0
	}
	for _, p := range a.Properties {
		if p.Key == "buildNumber" {
			if i, err := strconv.Atoi(p.Value); err == nil {
				return i
			}
		}
	}
	return 0
}

func (a *afyItem) GetBambooID() string {
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

func (a *afyItem) GetBranch() string {
	if a == nil {
		return ""
	}
	for _, p := range a.Properties {
		if p.Key == "gitBranch" {
			return p.Value
		}
	}
	return ""
}

func (a *afyItem) GetSHA() string {
	if a == nil {
		return ""
	}
	for _, p := range a.Properties {
		if p.Key == "gitSha" {
			return p.Value
		}
	}
	return ""
}

func (a *afyItem) GetShortSHA() string {
	if a == nil {
		return ""
	}
	if len(a.GetSHA()) < 7 {
		return a.GetSHA()
	}
	return a.GetSHA()[0:7]
}

func (a *afyItem) GetURL() string {
	if a == nil {
		return ""
	}
	for _, p := range a.Properties {
		if p.Key == "buildResults" {
			return p.Value
		}
	}
	return ""
}

func (a *afyItem) GetRepoURL() string {
	if a == nil {
		return ""
	}
	for _, p := range a.Properties {
		if p.Key == "gitRepo" {
			return strings.Replace(p.Value, ".git", "", -1)
		}
	}
	return ""
}

func (a *afyItem) GetCreated() time.Time {
	if a == nil {
		return time.Unix(0, 0)
	}
	return time.Now()
}

type afyItems []*afyItem

func (s afyItems) Len() int {
	return len(s)
}

func (s afyItems) Swap(i, j int) {
	s[i], s[j] = s[j], s[i]
}

func (s afyItems) Less(i, j int) bool {
	return s[i].Created.Before(s[j].Created)
}
