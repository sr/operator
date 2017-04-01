package breadapi

import (
	"bytes"
	"errors"
	"fmt"
	"sort"
	"strings"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"golang.org/x/net/context"

	"git.dev.pardot.com/Pardot/infrastructure/bread/chatbot"
	"git.dev.pardot.com/Pardot/infrastructure/bread/generated/pb"
)

const (
	master      = "master"
	pardot      = "pardot"
	maxBuildAge = 36 * time.Hour
)

// ECSDeployTargets is the list of projects that are deployed to Amazon ECS.
var ECSDeployTargets = []*DeployTarget{
	{
		Name:          "canoe",
		Canoe:         false,
		ECSCluster:    "canoe_production",
		ECSService:    "canoe",
		ContainerName: "canoe",
		Image:         "build/bread/canoe/app",
	},
	{
		Name:          "hal9000",
		Canoe:         false,
		ECSCluster:    "operator_production",
		ECSService:    "operator",
		ContainerName: "hal9000",
		Image:         "build/bread/hal9000/app",
	},
	{
		Name:          "operator",
		Canoe:         false,
		ECSCluster:    "operator_production",
		ECSService:    "operator",
		ContainerName: "operatord",
		Image:         "build/bread/operatord/app",
	},
	{
		Name:          "parbot",
		Canoe:         false,
		ECSCluster:    "parbot_production",
		ECSService:    "parbot",
		ContainerName: "parbot",
		Image:         "build/bread/parbot/app",
	},
	{
		Name:          "refocus",
		Canoe:         false,
		ECSCluster:    "refocus_production",
		ECSService:    "refocus",
		ContainerName: "refocus",
		Image:         "build/pardot-refocus/app",
	},
	{
		Name:          "teampass",
		Canoe:         false,
		ECSCluster:    "teampass",
		ECSService:    "teampass",
		ContainerName: "teampass",
		Image:         "build/bread/teampass/app",
	},
}

// A Deployer deploys builds to deployment targets.
type Deployer interface {
	ListTargets(context.Context) ([]*DeployTarget, error)
	ListBuilds(context.Context, *DeployTarget, string) ([]Build, error)
	Deploy(context.Context, chatbot.Messenger, *DeployRequest) (*chatbot.Message, error)
}

// A DeployTarget is a running service that can be deployed.
type DeployTarget struct {
	Name          string
	Canoe         bool
	ECSCluster    string
	ECSService    string
	ContainerName string
	Image         string
}

// A Build is a code repository checked out at a certain SHA1 that has been built
// into a deployable blob (such as a tarball or Docker image) and uploaded to
// an artifact store, such as Artifactory.
type Build interface {
	GetID() string
	GetURL() string
	GetArtifactURL() string
	GetBranch() string
	GetSHA() string
	GetShortSHA() string
	GetRepoURL() string
	GetCreated() time.Time
}

// A DeployRequest is user (as identified by the UserEmail field) request to
// deploy a build to a deployment target.
type DeployRequest struct {
	Target    *DeployTarget
	Build     Build
	UserEmail string
}

type CanoeConfig struct {
	URL    string
	APIKey string
}

type deployAPIServer struct {
	chatbot.Messenger
	ecs   Deployer
	canoe Deployer
	tz    *time.Location
}

// NewDeployServer returns a gRPC server that implements the bread.Deploy protobuf
// server interface and supports deploying to both Amazon EC2 Container Service (ECS)
// and Canoe.
func NewDeployServer(messenger chatbot.Messenger, ecs Deployer, canoe Deployer, tz *time.Location) (breadpb.DeployServer, error) {
	if messenger == nil {
		return nil, errors.New("required argument is nil: messenger")
	}
	if ecs == nil {
		return nil, errors.New("required argument is nil: ecs")
	}
	if canoe == nil {
		return nil, errors.New("required argument is nil: canoe")
	}
	if tz == nil {
		tz = time.UTC
	}
	return &deployAPIServer{messenger, ecs, canoe, tz}, nil
}

func (s *deployAPIServer) ListTargets(ctx context.Context, req *breadpb.ListTargetsRequest) (*breadpb.ListTargetsResponse, error) {
	targets := s.listTargets(ctx)
	names := make([]string, len(targets))
	for i, t := range targets {
		names[i] = t.Name
	}
	sort.Strings(names)
	return &breadpb.ListTargetsResponse{}, chatbot.SendRoomMessage(ctx, s.Messenger, &chatbot.Message{
		HTML: "Deployment targets: " + strings.Join(names, ", "),
		Text: strings.Join(names, " "),
	})
}

func (s *deployAPIServer) ListBuilds(ctx context.Context, req *breadpb.ListBuildsRequest) (*breadpb.ListBuildsResponse, error) {
	if req.Target == "" {
		req.Target = pardot
	}
	var (
		err    error
		target *DeployTarget
		builds []Build
	)
	targets := s.listTargets(ctx)
	for _, t := range targets {
		if t.Name == req.Target {
			target = t
			break
		}
	}
	if target == nil {
		return nil, fmt.Errorf("No such deployment target: %s", req.Target)
	}
	if target.Canoe && req.Branch == "" {
		req.Branch = master
	}
	builds, err = s.listBuilds(ctx, target, req.Branch)
	if err != nil {
		return nil, err
	}
	if len(builds) == 0 {
		return nil, fmt.Errorf("No build for %s@%s", req.Target, req.Branch)
	}
	var txt, html bytes.Buffer
	_, _ = html.WriteString("<table><tr><th>Build</th><th>Commit</th><th>Completed</th><th></th></tr>")
	i := 0
	for _, b := range builds {
		if i >= 10 {
			break
		}
		fmt.Fprintf(&txt, "%s\t%s\n", b.GetID(), b.GetArtifactURL())
		fmt.Fprintf(
			&html,
			"<tr><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>\n",
			fmt.Sprintf("<code>%s</code>", b.GetID()),
			fmt.Sprintf(`<a href="%s/tree/%s">%s@%s</a>`, b.GetRepoURL(), b.GetBranch(), b.GetBranch(), b.GetShortSHA()),
			b.GetCreated().In(s.tz).Format("2006-01-02 15:04:05 MST"),
			fmt.Sprintf(`<a href="%s">View details</a>`, b.GetURL()),
		)
		i++
	}
	return &breadpb.ListBuildsResponse{},
		chatbot.SendRoomMessage(ctx, s.Messenger, &chatbot.Message{Text: txt.String(), HTML: html.String()})
}

var eggs = map[string]string{
	"smiley": "https://pbs.twimg.com/profile_images/2799017051/9b51b94ade9d8a509b28ee291a2dba86_400x400.png",
	"hunter": "https://hipchat.dev.pardot.com/files/1/3/IynoW4Fx0zPhtVX/Screen%20Shot%202016-09-28%20at%206.11.57%20PM.png",
	"BIJ":    "http://abload.de/img/gowron1eykyk.gif",
}

func (s *deployAPIServer) Trigger(ctx context.Context, req *breadpb.TriggerRequest) (*breadpb.TriggerResponse, error) {
	if v, ok := eggs[req.Target]; ok {
		return &breadpb.TriggerResponse{},
			chatbot.SendRoomMessage(ctx, s.Messenger, &chatbot.Message{
				Text:  v,
				Color: "green",
			})
	}
	if req.Build == "" && req.Branch == "" {
		req.Branch = master
	}
	if req.Build != "" && req.Branch != "" {
		return nil, errors.New("Please specify either a branch or a build to deploy, but not both")
	}
	var (
		target *DeployTarget
		msg    *chatbot.Message
	)
	targets := s.listTargets(ctx)
	for _, t := range targets {
		if t.Name == req.Target {
			target = t
			break
		}
	}
	if target == nil {
		return nil, fmt.Errorf("No such deployment target: %s", req.Target)
	}
	var build Build
	builds, err := s.listBuilds(ctx, target, req.Branch)
	if req.Build == "" {
		if len(builds) == 0 {
			return nil, fmt.Errorf("No build found for branch %s of %s", req.Branch, req.Target)
		}
		build = builds[0]
	} else {
		for _, b := range builds {
			if b.GetID() == req.Build {
				build = b
			}
		}
		if build == nil {
			return nil, fmt.Errorf("No such build %s", req.Build)
		}
	}
	if time.Since(build.GetCreated()) > maxBuildAge {
		return nil, fmt.Errorf(
			"Unable to deploy build %s (branch %s) because it was created on %s which is more than %s ago",
			build.GetID(),
			build.GetBranch(),
			build.GetCreated().In(s.tz).Format("2006-01-02 at 15:04:05 MST"),
			maxBuildAge,
		)
	}
	deploy := &DeployRequest{
		Target:    target,
		Build:     build,
		UserEmail: chatbot.EmailFromContext(ctx),
	}
	if target.Canoe {
		msg, err = s.canoe.Deploy(ctx, s.Messenger, deploy)
	} else {
		msg, err = s.ecs.Deploy(ctx, s.Messenger, deploy)
	}
	if err != nil {
		return nil, err
	}
	return &breadpb.TriggerResponse{Message: msg.Text}, chatbot.SendRoomMessage(ctx, s.Messenger, msg)
}

var ecsRunning = aws.String("RUNNING")

func (s *deployAPIServer) listTargets(ctx context.Context) (targets []*DeployTarget) {
	targets, _ = s.ecs.ListTargets(ctx)
	if t, err := s.canoe.ListTargets(ctx); err == nil {
		targets = append(targets, t...)
	} else {
		_ = chatbot.SendRoomMessage(ctx, s.Messenger, &chatbot.Message{
			Text:  fmt.Sprintf("Could not get list of projects from Canoe: %v", err),
			HTML:  fmt.Sprintf("Could not get list of projects from Canoe: <code>%v</code>", err),
			Color: "red",
		})
	}
	return targets
}

func (s *deployAPIServer) listBuilds(ctx context.Context, t *DeployTarget, branch string) ([]Build, error) {
	if t.Canoe {
		return s.canoe.ListBuilds(ctx, t, branch)
	}
	return s.ecs.ListBuilds(ctx, t, branch)
}
