package breadapi_test

import (
	"errors"
	"fmt"
	"strings"
	"testing"
	"time"

	"golang.org/x/net/context"
	"google.golang.org/grpc/metadata"

	"git.dev.pardot.com/Pardot/infrastructure/bread/api"
	"git.dev.pardot.com/Pardot/infrastructure/bread/generated/pb"
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

type fakeDeployer struct {
	builds  []breadapi.Build
	targets []*breadapi.DeployTarget
}

func (d *fakeDeployer) ListTargets(context.Context) ([]*breadapi.DeployTarget, error) {
	return d.targets, nil
}

func (d *fakeDeployer) ListBuilds(ctx context.Context, t *breadapi.DeployTarget, branch string) ([]breadapi.Build, error) {
	var builds []breadapi.Build
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

func (d *fakeDeployer) Deploy(ctx context.Context, m breadapi.Messenger, req *breadapi.DeployRequest) (*breadapi.ChatMessage, error) {
	return &breadapi.ChatMessage{
		Text: fmt.Sprintf(
			"deployed target=%s build=%s branch=%s",
			req.Target.Name,
			req.Build.GetID(),
			req.Build.GetBranch(),
		),
	}, nil
}

func TestDeployServer(t *testing.T) {
	messenger := func(ctx context.Context, msg *breadapi.ChatMessage) error {
		return nil
	}
	deployer := &fakeDeployer{
		targets: []*breadapi.DeployTarget{
			{
				Name: "pardot",
			},
			{
				Name: "hal9000",
			},
		},
		builds: []breadapi.Build{
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
	server, err := breadapi.NewDeployServer(messenger, deployer, deployer, nil)
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

			resp, err := server.Trigger(
				metadata.NewContext(
					context.Background(),
					metadata.MD{"chat_room_id": []string{"1"}},
				),
				&breadpb.TriggerRequest{
					Target: tc.target,
					Build:  tc.build,
					Branch: tc.branch,
				},
			)
			if tc.err == nil {
				if err != nil {
					t.Errorf("expected no error but got %s", err)
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
