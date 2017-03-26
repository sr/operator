package bread_test

import (
	"errors"
	"fmt"
	"strings"
	"testing"
	"time"

	"github.com/sr/operator"
	"golang.org/x/net/context"

	"git.dev.pardot.com/Pardot/infrastructure/bread"
	"git.dev.pardot.com/Pardot/infrastructure/bread/pb"
)

type fakeBuild struct {
	ID          string
	URL         string
	ArtifactURL string
	Branch      string
	SHA         string
	RepoURL     string
	Created     time.Time
}

func (b *fakeBuild) GetID() string {
	return b.ID
}

func (b *fakeBuild) GetURL() string {
	return b.URL
}

func (b *fakeBuild) GetArtifactURL() string {
	return b.ArtifactURL
}

func (b *fakeBuild) GetBranch() string {
	return b.Branch
}

func (b *fakeBuild) GetSHA() string {
	return b.SHA
}

func (b *fakeBuild) GetShortSHA() string {
	if len(b.SHA) <= 7 {
		return b.SHA
	}
	return b.SHA[0:7]
}

func (b *fakeBuild) GetRepoURL() string {
	return b.RepoURL
}

func (b *fakeBuild) GetCreated() time.Time {
	return b.Created
}

type fakeSender struct{}

func (c *fakeSender) Send(_ context.Context, _ *operator.Source, _ string, _ *operator.Message) error {
	return nil
}

type fakeDeployer struct {
	builds  []bread.Build
	targets []*bread.DeployTarget
}

func (d *fakeDeployer) ListTargets(context.Context) ([]*bread.DeployTarget, error) {
	return d.targets, nil
}

func (d *fakeDeployer) ListBuilds(ctx context.Context, t *bread.DeployTarget, branch string) ([]bread.Build, error) {
	var builds []bread.Build
	if branch == "" {
		for _, b := range d.builds {
			if b.GetRepoURL() == "" || b.GetRepoURL() == t.Name {
				builds = append(builds, b)
			}
		}
		return builds, nil
	}
	for _, b := range d.builds {
		if (b.GetRepoURL() == "" || b.GetRepoURL() == t.Name) && b.GetBranch() == branch {
			builds = append(builds, b)
		}
	}
	return builds, nil
}

func (d *fakeDeployer) Deploy(ctx context.Context, s *operator.RequestSender, req *bread.DeployRequest) (*operator.Message, error) {
	return &operator.Message{
		Text: fmt.Sprintf(
			"deployed target=%s build=%s branch=%s",
			req.Target.Name,
			req.Build.GetID(),
			req.Build.GetBranch(),
		),
	}, nil
}

func TestDeployServer(t *testing.T) {
	sender := &fakeSender{}
	deployer := &fakeDeployer{
		targets: []*bread.DeployTarget{
			{
				Name: "pardot",
			},
			{
				Name: "hal9000",
			},
		},
		builds: []bread.Build{
			&fakeBuild{
				ID:      "1",
				Branch:  "master",
				Created: time.Now(),
				RepoURL: "pardot",
			},
			&fakeBuild{
				ID:      "2",
				Branch:  "master",
				Created: time.Now(),
				RepoURL: "hal9000",
			},
			&fakeBuild{
				ID:      "old",
				Created: time.Now().Add(-36 * time.Hour),
				RepoURL: "pardot",
			},
		},
	}
	server, err := bread.NewDeployServer(sender, deployer, deployer, nil)
	if err != nil {
		t.Fatal(err)
	}
	for _, tc := range []struct {
		target string
		build  string
		branch string
		resp   string
		err    error
	}{
		{"pardot", "1", "", "target=pardot build=1 branch=master", nil},
		{"pardot", "", "", "target=pardot build=1 branch=master", nil},
		{"hal9000", "", "", "target=hal9000 build=2 branch=master", nil},
		{"hal9000", "", "boomtown", "", errors.New("No build found for branch boomtown of hal9000")},
		{"pardot", "old", "", "", errors.New("because it was created on")},
		{"bread", "1", "", "", errors.New("No such deployment target: bread")},
		{"pardot", "1", "master", "", errors.New(", but not both")},
		{"pardot", "", "not-found", "", errors.New("No build found for branch not-found")},
	} {
		t.Run(fmt.Sprintf("%s_%s_%s", tc.target, tc.build, tc.branch), func(t *testing.T) {
			resp, err := server.Trigger(context.Background(), &breadpb.TriggerRequest{
				Request: &operator.Request{Source: &operator.Source{}},
				Target:  tc.target,
				Build:   tc.build,
				Branch:  tc.branch,
			})
			if tc.err == nil {
				if err != nil {
					t.Errorf("expected no error bit got %s", err)
				} else if !strings.Contains(resp.Message, tc.resp) {
					t.Errorf("expected response message `%s` but got %s", tc.resp, resp.Message)
				}
			} else {
				if err == nil {
					t.Errorf("expect an error for but got none")
					if resp.Message != tc.resp {
						t.Errorf("expected response message `%s` for but got %s", tc.resp, resp.Message)
					}
				} else if !strings.Contains(err.Error(), tc.err.Error()) {
					t.Errorf("expected error to match `%s` but got: %s", tc.err, err)
				}
			}
		})
	}
}
