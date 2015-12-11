package buildkite

import (
	"bytes"
	"fmt"
	"text/tabwriter"

	"github.com/sr/operator/src/operator"
	buildkiteapi "github.com/wolfeidau/go-buildkite/buildkite"
	"golang.org/x/net/context"
)

type server struct {
	client *buildkiteapi.Client
}

func newServer(client *buildkiteapi.Client) *server {
	return &server{client}
}

func (s *server) ProjectsStatus(
	ctx context.Context,
	request *ProjectsStatusRequest,
) (*ProjectsStatusResponse, error) {
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
				fmt.Sprintf("https://buildkite.com/%s/%s", *organization.Slug, *project.Slug), // TODO use WebURL
			)
		}
	}
	w.Flush()
	return &ProjectsStatusResponse{
		Output: &operator.Output{
			PlainText: output.String(),
		},
	}, nil
}

func (s *server) fetchAllOrganizations() ([]buildkiteapi.Organization, error) {
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

func (s *server) fetchAllOrganizationProjects(
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
