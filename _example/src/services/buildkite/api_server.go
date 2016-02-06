package buildkite

import (
	"bytes"
	"errors"
	"fmt"
	"strings"
	"text/tabwriter"

	"github.com/sr/operator"
	buildkiteapi "github.com/wolfeidau/go-buildkite/buildkite"
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
	organizations, err := s.fetchAllOrganizations()
	if err != nil {
		return nil, err
	}
	output := bytes.NewBufferString("")
	w := new(tabwriter.Writer)
	w.Init(output, 0, 8, 1, '\t', 0)
	fmt.Fprintf(w, "%s\t%s\t%s\t%s\n", "NAME", "STATUS", "BRANCH", "URL")
	for _, organization := range organizations {
		projects, err := s.fetchAllOrganizationProjects(organization)
		if err != nil {
			return nil, err
		}
		for _, project := range projects {
			fmt.Fprintf(
				w,
				"%s\t%s\t%s\t%s\n",
				fmt.Sprintf("%s/%s", *organization.Slug, *project.Slug),
				*project.FeaturedBuild.State,
				*project.FeaturedBuild.Branch,
				*project.WebURL,
			)
		}
	}
	w.Flush()
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
		"",
		"",
		buildkiteapi.ListOptions{Page: 1, PerPage: buildsLimit},
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
		builds, _, err = s.client.Builds.ListByProject(p[0], p[1], options)
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
	w.Flush()
	return &ListBuildsResponse{
		Output: &operator.Output{
			PlainText: output.String(),
		},
	}, nil
}

func (s *apiServer) fetchAllOrganizations() ([]buildkiteapi.Organization, error) {
	var organizations []buildkiteapi.Organization
	pageNumber := 1
	for {
		collection, response, err := s.client.Organizations.List(
			&buildkiteapi.OrganizationListOptions{
				buildkiteapi.ListOptions{
					Page:    pageNumber,
					PerPage: 100,
				},
			},
		)
		if err != nil {
			return nil, err
		}
		for _, organization := range collection {
			organizations = append(organizations, organization)
		}
		if response.NextPage == 0 {
			break
		}
		pageNumber = pageNumber + 1
	}
	return organizations, nil
}

func (s *apiServer) fetchAllOrganizationProjects(
	organization buildkiteapi.Organization,
) ([]buildkiteapi.Project, error) {
	var projects []buildkiteapi.Project
	pageNumber := 1
	for {
		collection, response, err := s.client.Projects.List(
			*organization.Slug,
			&buildkiteapi.ProjectListOptions{
				buildkiteapi.ListOptions{
					Page:    pageNumber,
					PerPage: 100,
				},
			},
		)
		if err != nil {
			return nil, err
		}
		for _, project := range collection {
			projects = append(projects, project)
		}
		if response.NextPage == 0 {
			break
		}
		pageNumber = pageNumber + 1
	}
	return projects, nil
}
