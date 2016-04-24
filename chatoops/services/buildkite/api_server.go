package buildkite

import (
	"bytes"
	"errors"
	"fmt"
	"strings"
	"text/tabwriter"

	buildkiteapi "github.com/buildkite/go-buildkite/buildkite"
	"github.com/sr/operator"
	"golang.org/x/net/context"
)

const buildsLimit = 10

type apiServer struct {
	client *buildkiteapi.Client
}

func newAPIServer(client *buildkiteapi.Client) *apiServer {
	return &apiServer{client}
}

func (s *apiServer) Status(
	ctx context.Context,
	request *StatusRequest,
) (*StatusResponse, error) {
	output := bytes.NewBufferString("")
	w := new(tabwriter.Writer)
	w.Init(output, 0, 8, 1, '\t', 0)
	fmt.Fprintf(w, "%s\t%s\t%s\t%s\n", "NAME", "STATUS", "BRANCH", "URL")
	// TODO(sr) The API for this has changed and I am too lazy to fix it. See:
	// https://github.com/buildkite/go-buildkite/pull/7
	fmt.Fprintf(w, "TODO")
	if err := w.Flush(); err != nil {
		return nil, err
	}
	return &StatusResponse{
		Output: &operator.Output{
			PlainText: output.String(),
		},
	}, nil
}

func (s *apiServer) ListBuilds(
	ctx context.Context,
	request *ListBuildsRequest,
) (*ListBuildsResponse, error) {
	options := &buildkiteapi.BuildsListOptions{
		State:       []string{},
		Branch:      "",
		ListOptions: buildkiteapi.ListOptions{Page: 1, PerPage: buildsLimit},
	}
	var (
		builds []buildkiteapi.Build
		err    error
	)
	if request.ProjectSlug == "" {
		builds, _, err = s.client.Builds.List(options)
	} else {
		p := strings.SplitN(request.ProjectSlug, "/", 2)
		if len(p) != 2 {
			return nil, errors.New("invalid slug. must be in the form org/repo")
		}
		builds, _, err = s.client.Builds.ListByPipeline(p[0], p[1], options)
	}
	if err != nil {
		return nil, err
	}
	output := bytes.NewBufferString("")
	w := new(tabwriter.Writer)
	w.Init(output, 0, 8, 1, '\t', 0)
	fmt.Fprintf(w, "%s\t%s\t%s\t%s\n", "ID", "STATUS", "BRANCH", "URL")
	for _, build := range builds {
		fmt.Fprintf(
			w,
			"%d\t%s\t%s\t%s\n",
			*build.Number,
			*build.State,
			*build.Branch,
			*build.WebURL,
		)
	}
	if err := w.Flush(); err != nil {
		return nil, err
	}
	return &ListBuildsResponse{
		Output: &operator.Output{
			PlainText: output.String(),
		},
	}, nil
}
