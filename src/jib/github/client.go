package github

import (
	"fmt"
	"net/http"
	"net/url"

	gogithub "github.com/google/go-github/github"
)

const (
	githubMaxPerPage = 100
)

// Client is a pared-down version of the GitHub client from
// github.com/google/go-github, focusing on higher-level, safe or otherwise
// idempotent operations
type Client interface {
	GetOpenPullRequests(owner, repo string) ([]*PullRequest, error)
	GetIssueComments(owner, repo string, number int) ([]*IssueComment, error)
	GetUserPermissionLevel(owner, repo, login string) (PermissionLevel, error)
	MergePullRequest(owner, repo string, number int, commitMessage string) error
}

// client is the real implementation of Client.
type client struct {
	gh *gogithub.Client
}

func NewClient(baseURL *url.URL, username string, apiToken string) Client {
	transport := &gogithub.BasicAuthTransport{
		Username:  username,
		Password:  apiToken,
		Transport: http.DefaultTransport,
	}

	gh := gogithub.NewClient(transport.Client())
	gh.BaseURL = baseURL

	return &client{
		gh: gh,
	}
}

func (c *client) GetOpenPullRequests(owner, repo string) ([]*PullRequest, error) {
	opt := &gogithub.PullRequestListOptions{
		State:     "open",
		Sort:      "created",
		Direction: "desc",
		ListOptions: gogithub.ListOptions{
			PerPage: githubMaxPerPage,
		},
	}

	allPullRequests := []*PullRequest{}
	for {
		pullRequests, resp, err := c.gh.PullRequests.List(owner, repo, opt)
		if err != nil {
			return nil, err
		}

		for _, pullRequest := range pullRequests {
			if pullRequest.Number == nil {
				continue
			}

			// Refetching the pull request from the individual route
			// is required to get mergeability
			fullPullRequest, _, err := c.gh.PullRequests.Get(owner, repo, *pullRequest.Number)
			if err != nil {
				return nil, err
			}

			wrapped, err := c.wrapPullRequest(owner, repo, fullPullRequest)
			if err != nil {
				return nil, err
			}
			allPullRequests = append(allPullRequests, wrapped)
		}

		if resp.NextPage == 0 {
			break
		}
		opt.ListOptions.Page = resp.NextPage
	}

	return allPullRequests, nil
}

func (c *client) wrapPullRequest(owner, repo string, pullRequest *gogithub.PullRequest) (*PullRequest, error) {
	if pullRequest.Number == nil {
		return nil, fmt.Errorf("pull request number was nil: %+v", pullRequest)
	} else if pullRequest.State == nil {
		return nil, fmt.Errorf("pull request state was nil: %+v", pullRequest)
	} else if pullRequest.Title == nil {
		return nil, fmt.Errorf("pull request title was nil: %+v", pullRequest)
	}

	wrapped := &PullRequest{
		Owner:      owner,
		Repository: repo,
		Number:     *pullRequest.Number,
		State:      *pullRequest.State,
		Title:      *pullRequest.Title,
		Mergeable:  pullRequest.Mergeable,
	}
	return wrapped, nil
}

func (c *client) GetIssueComments(owner, repo string, number int) ([]*IssueComment, error) {
	opt := &gogithub.IssueListCommentsOptions{
		Sort:      "created",
		Direction: "asc",
		ListOptions: gogithub.ListOptions{
			PerPage: githubMaxPerPage,
		},
	}

	allComments := []*IssueComment{}
	for {
		comments, resp, err := c.gh.Issues.ListComments(owner, repo, number, opt)
		if err != nil {
			return nil, err
		}

		for _, comment := range comments {
			wrapped, err := c.wrapIssueComment(comment)
			if err != nil {
				return nil, err
			}
			allComments = append(allComments, wrapped)
		}

		if resp.NextPage == 0 {
			break
		}
		opt.ListOptions.Page = resp.NextPage
	}

	return allComments, nil
}

func (c *client) wrapIssueComment(comment *gogithub.IssueComment) (*IssueComment, error) {
	if comment.ID == nil {
		return nil, fmt.Errorf("comment ID was nil: %+v", comment)
	} else if comment.User == nil {
		return nil, fmt.Errorf("comment User was nil: %+v", comment)
	} else if comment.Body == nil {
		return nil, fmt.Errorf("comment Body was nil: %+v", comment)
	}

	wrappedUser, err := c.wrapUser(comment.User)
	if err != nil {
		return nil, err
	}

	wrapped := &IssueComment{
		ID:   *comment.ID,
		User: wrappedUser,
		Body: *comment.Body,
	}
	return wrapped, nil
}

func (c *client) wrapUser(user *gogithub.User) (*User, error) {
	if user.Login == nil {
		return nil, fmt.Errorf("user Login was nil: %+v", user)
	}

	wrapped := &User{
		Login: *user.Login,
	}
	return wrapped, nil
}

func (c *client) GetUserPermissionLevel(org, repo, login string) (PermissionLevel, error) {
	rpl, _, err := c.gh.Repositories.GetPermissionLevel(org, repo, login)
	if err != nil {
		return "", err
	} else if rpl.Permission == nil {
		return "", fmt.Errorf("permission was nil: %+v", rpl)
	}

	return PermissionLevel(*rpl.Permission), nil
}

func (c *client) MergePullRequest(org, repo string, number int, commitMessage string) error {
	opt := &gogithub.PullRequestOptions{}
	_, _, err := c.gh.PullRequests.Merge(org, repo, number, commitMessage, opt)
	return err
}
