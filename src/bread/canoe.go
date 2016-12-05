package bread

import (
	"encoding/json"
	"errors"
	"fmt"
	"io/ioutil"
	"net/http"
	"net/url"
	"strings"
	"time"

	"github.com/sr/operator"
	"github.com/sr/operator/hipchat"
	"golang.org/x/net/context"
	"golang.org/x/net/context/ctxhttp"

	"bread/swagger/client/canoe"
	"bread/swagger/models"
)

type canoeDeployer struct {
	http   *http.Client
	canoe  *CanoeConfig
	client CanoeClient
}

type canoeProject struct {
	Name string `json:"name"`
}

type canoeBuild struct {
	ArtifactURL string    `json:"artifact_url"`
	BuildID     string    `json:"build_id"`
	RepoURL     string    `json:"repo_url"`
	URL         string    `json:"url"`
	Branch      string    `json:"branch"`
	BuildNumber int       `json:"build_number"`
	SHA         string    `json:"sha"`
	PassedCI    bool      `json:"passed_ci"`
	CreatedAt   time.Time `json:"created_at"`
}

func (d *canoeDeployer) ListTargets(ctx context.Context) (targets []*DeployTarget, err error) {
	var resp *http.Response
	if resp, err = d.doCanoe(ctx, "GET", "/api/projects", ""); err == nil {
		defer func() { _ = resp.Body.Close() }()
		var projs []*canoeProject
		if err := json.NewDecoder(resp.Body).Decode(&projs); err == nil {
			for _, p := range projs {
				targets = append(targets, &DeployTarget{Name: p.Name, Canoe: true})
			}
		}
	}
	return targets, err
}

func (d *canoeDeployer) ListBuilds(ctx context.Context, t *DeployTarget, branch string) ([]Build, error) {
	resp, err := d.doCanoe(
		ctx,
		"GET",
		fmt.Sprintf("/api/projects/%s/branches/%s/builds", t.Name, branch),
		"",
	)
	if err != nil {
		return nil, err
	}
	defer func() { _ = resp.Body.Close() }()
	var data []*canoeBuild
	if err := json.NewDecoder(resp.Body).Decode(&data); err != nil {
		return nil, err
	}
	var builds []Build
	for _, b := range data {
		builds = append(builds, Build(b))
	}
	return builds, nil
}

func (d *canoeDeployer) Deploy(ctx context.Context, sender *operator.RequestSender, req *DeployRequest) (*operator.Message, error) {
	if req.UserEmail == "" {
		return nil, errors.New("unable to deploy without a user")
	}
	resp, err := d.client.CreateDeploy(canoe.NewCreateDeployParamsWithContext(ctx).
		WithBody(&models.CanoeCreateDeployRequest{
			UserEmail:   req.UserEmail,
			Project:     req.Target.Name,
			ArtifactURL: req.Build.GetArtifactURL(),
		}),
	)
	if err != nil {
		return nil, err
	}
	if resp.Payload.Error {
		return nil, errors.New(resp.Payload.Message)
	}
	deployURL := fmt.Sprintf("%s/projects/%s/deploys/%d?watching=1", d.canoe.URL, req.Target.Name, resp.Payload.DeployID)
	return &operator.Message{
		Text: deployURL,
		HTML: fmt.Sprintf(
			`Deployment of %s (branch %s) to %s progress. Follow along here: <a href="%s">#%d</a>`,
			fmt.Sprintf(`<a href="%s">%s</a>`, req.Build.GetURL(), req.Build.GetID()),
			req.Build.GetBranch(),
			req.Target.Name,
			deployURL,
			resp.Payload.DeployID,
		),
		Options: &operatorhipchat.MessageOptions{
			Color: "green",
		},
	}, nil
}

func (d *canoeDeployer) doCanoe(ctx context.Context, meth, path, body string) (*http.Response, error) {
	req, err := http.NewRequest(meth, d.canoe.URL+path, strings.NewReader(body))
	if err != nil {
		return nil, err
	}
	req.Header.Set("X-Api-Token", d.canoe.APIKey)
	if body != "" {
		req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	}
	resp, err := ctxhttp.Do(ctx, d.http, req)
	if err != nil {
		return nil, err
	}
	if resp.StatusCode != http.StatusOK {
		if body, err := ioutil.ReadAll(resp.Body); err == nil {
			return nil, fmt.Errorf("canoe API request failed with status %d and body: %s", resp.StatusCode, body)
		}
		return nil, fmt.Errorf("canoe API request failed with status %d", resp.StatusCode)
	}
	return resp, nil
}

func (a *canoeBuild) GetID() string {
	if a == nil || a.GetURL() == "" {
		return ""
	}
	if a.BuildID != "" {
		return a.BuildID
	}
	u, err := url.Parse(a.GetURL())
	if err != nil {
		return ""
	}
	// https://bamboo.dev.pardot.com/browse/BREAD-BREAD327-GOL-10
	parts := strings.Split(u.Path, "/")
	if len(parts) != 3 {
		return ""
	}
	return parts[2]
}

func (a *canoeBuild) GetBranch() string {
	if a == nil {
		return ""
	}
	return a.Branch
}

func (a *canoeBuild) GetSHA() string {
	if a == nil {
		return ""
	}
	return a.SHA
}

func (a *canoeBuild) GetShortSHA() string {
	if a == nil {
		return ""
	}
	if len(a.SHA) < 7 {
		return a.SHA
	}
	return a.SHA[0:7]
}

func (a *canoeBuild) GetURL() string {
	if a == nil {
		return ""
	}
	return a.URL
}

func (a *canoeBuild) GetArtifactURL() string {
	if a == nil {
		return ""
	}
	return a.ArtifactURL
}

func (a *canoeBuild) GetRepoURL() string {
	if a == nil {
		return ""
	}
	return a.RepoURL
}

func (a *canoeBuild) GetCreated() time.Time {
	if a == nil {
		return time.Unix(0, 0)
	}
	return a.CreatedAt
}
