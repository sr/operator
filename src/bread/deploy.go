package bread

import (
	"bytes"
	"errors"
	"fmt"
	"net/http"
	"sort"
	"strconv"
	"strings"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/sr/operator"
	"github.com/sr/operator/hipchat"
	"golang.org/x/net/context"

	"bread/pb"
)

const (
	bambooURL = "https://bamboo.dev.pardot.com"
	master    = "master"
	pardot    = "pardot"
)

type deployer interface {
	listTargets(context.Context) ([]*DeployTarget, error)
	listBuilds(context.Context, *DeployTarget, string) ([]build, error)
	deploy(context.Context, *operator.Request, *DeployTarget, build) (*operator.Message, error)
}

type build interface {
	GetNumber() int
	GetBambooID() string
	GetBranch() string
	GetSHA() string
	GetShortSHA() string
	GetURL() string
	GetRepoURL() string
	GetCreated() time.Time
}

type deployAPIServer struct {
	operator.Replier
	conf  *DeployConfig
	http  *http.Client
	tz    *time.Location
	canoe deployer
	ecs   deployer
}

func (s *deployAPIServer) ListTargets(ctx context.Context, req *breadpb.ListTargetsRequest) (*operator.Response, error) {
	targets := s.listTargets(ctx, req)
	names := make([]string, len(targets))
	for i, t := range targets {
		names[i] = t.Name
	}
	sort.Strings(names)
	return operator.Reply(s, ctx, req, &operator.Message{
		HTML: "Deployment targets: " + strings.Join(names, ", "),
		Text: strings.Join(names, " "),
	})
}

func (s *deployAPIServer) ListBuilds(ctx context.Context, req *breadpb.ListBuildsRequest) (*operator.Response, error) {
	if req.Target == "" {
		req.Target = pardot
	}
	var (
		err    error
		target *DeployTarget
		builds []build
	)
	targets := s.listTargets(ctx, req)
	for _, t := range targets {
		if t.Name == req.Target {
			target = t
			break
		}
	}
	if target == nil {
		return nil, fmt.Errorf("No such deployment target: %s", req.Target)
	}
	builds, err = s.listBuilds(ctx, target, req.Branch)
	if err != nil {
		return nil, err
	}
	if len(builds) == 0 {
		return operator.Reply(s, ctx, req, &operator.Message{
			Text: "",
			HTML: fmt.Sprintf("No build for %s@%s", req.Target, req.Branch),
		})
	}
	var txt, html bytes.Buffer
	_, _ = html.WriteString("<table><tr><th>Build</th><th>Branch</th><th>Completed</th></tr>")
	i := 0
	for _, b := range builds {
		if i >= 10 {
			break
		}
		fmt.Fprintf(&txt, "%d %s@%s %s\n", b.GetNumber(), b.GetBranch(), b.GetShortSHA(), b.GetCreated())
		fmt.Fprintf(
			&html,
			"<tr><td>%s</td><td>%s</td><td>%s</td></tr>\n",
			fmt.Sprintf(`<a href="%s">%d</a>`, b.GetURL(), b.GetNumber()),
			fmt.Sprintf(`<a href="%s/tree/%s">%s@%s</a>`, b.GetRepoURL(), b.GetBranch(), b.GetBranch(), b.GetShortSHA()),
			b.GetCreated().In(s.tz),
		)
		i++
	}
	return operator.Reply(s, ctx, req, &operator.Message{Text: txt.String(), HTML: html.String()})
}

var eggs = map[string]string{
	"smiley": "https://pbs.twimg.com/profile_images/2799017051/9b51b94ade9d8a509b28ee291a2dba86_400x400.png",
	"hunter": "https://hipchat.dev.pardot.com/files/1/3/IynoW4Fx0zPhtVX/Screen%20Shot%202016-09-28%20at%206.11.57%20PM.png",
}

func (s *deployAPIServer) Trigger(ctx context.Context, req *breadpb.TriggerRequest) (*operator.Response, error) {
	if req.GetRequest() == nil {
		return nil, errors.New("invalid request")
	}
	if v, ok := eggs[req.Target]; ok {
		return operator.Reply(s, ctx, req, &operator.Message{
			Text: v,
			Options: &operatorhipchat.MessageOptions{
				Color: "green",
			},
		})
	}
	buildID, err := strconv.Atoi(req.Build)
	if err != nil {
		return nil, fmt.Errorf("Invalid build: %#v", req.Build)
	}
	var (
		target *DeployTarget
		msg    *operator.Message
	)
	targets := s.listTargets(ctx, req)
	for _, t := range targets {
		if t.Name == req.Target {
			target = t
			break
		}
	}
	if target == nil {
		return nil, fmt.Errorf("No such deployment target: %s", req.Target)
	}
	var build build
	builds, err := s.listBuilds(ctx, target, "")
	for _, b := range builds {
		if b.GetNumber() == buildID {
			build = b
		}
	}
	if build == nil {
		return nil, fmt.Errorf("No such build %s", req.Build)
	}
	if target.Canoe {
		msg, err = s.canoe.deploy(ctx, req.GetRequest(), target, build)
	} else {
		msg, err = s.ecs.deploy(ctx, req.GetRequest(), target, build)
	}
	if err != nil {
		return nil, err
	}
	return operator.Reply(s, ctx, req, msg)
}

var ecsRunning = aws.String("RUNNING")

func (s *deployAPIServer) listTargets(ctx context.Context, req operator.Requester) (targets []*DeployTarget) {
	targets, _ = s.ecs.listTargets(ctx)
	if t, err := s.canoe.listTargets(ctx); err == nil {
		targets = append(targets, t...)
	} else {
		_, _ = operator.Reply(s, ctx, req, &operator.Message{
			Text: fmt.Sprintf("Could not get list of projects from Canoe: %v", err),
			HTML: fmt.Sprintf("Could not get list of projects from Canoe: <code>%v</code>", err),
			Options: &operatorhipchat.MessageOptions{
				Color: "red",
			},
		})
	}
	return targets
}

func (s *deployAPIServer) listBuilds(ctx context.Context, t *DeployTarget, branch string) (builds []build, err error) {
	if t.Canoe {
		if branch == "" {
			branch = master
		}
		builds, err = s.canoe.listBuilds(ctx, t, branch)
	} else {
		builds, err = s.ecs.listBuilds(ctx, t, "")
	}
	return builds, err
}
