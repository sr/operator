package github

import (
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"net/url"
	"strings"

	gogithub "github.com/google/go-github/github"
)

const (
	githubMaxPerPage = 100
)

// Client is a pared-down version of the GitHub client from
// github.com/google/go-github, focusing on higher-level, safe or otherwise
// idempotent operations
type Client interface {
	Username() string
	GetOpenPullRequests(owner, repo string) ([]*PullRequest, error)
	GetIssueComments(owner, repo string, number int) ([]*IssueComment, error)
	GetUserPermissionLevel(owner, repo, login string) (PermissionLevel, error)
	MergePullRequest(owner, repo string, number int, commitMessage string) error
	PostIssueComment(owner, repo string, number int, comment *IssueReplyComment) error
}

// client is the real implementation of Client.
type client struct {
	username string
	gh       *gogithub.Client
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
		username: username,
		gh:       gh,
	}
}

func (c *client) Username() string {
	return c.username
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
	} else if pullRequest.UpdatedAt == nil {
		return nil, fmt.Errorf("pull request updated at was nil: %+v", pullRequest)
	}

	wrapped := &PullRequest{
		Owner:      owner,
		Repository: repo,
		Number:     *pullRequest.Number,
		State:      *pullRequest.State,
		Title:      *pullRequest.Title,
		UpdatedAt:  *pullRequest.UpdatedAt,
		Mergeable:  pullRequest.Mergeable,
	}
	return wrapped, nil
}

func (c *client) GetIssueComments(owner, repo string, number int) ([]*IssueComment, error) {
	opt := &gogithub.IssueListCommentsOptions{
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
		return nil, fmt.Errorf("comment user was nil: %+v", comment)
	} else if comment.Body == nil {
		return nil, fmt.Errorf("comment body was nil: %+v", comment)
	} else if comment.CreatedAt == nil {
		return nil, fmt.Errorf("comment created at was nil: %+v", comment)
	} else if comment.UpdatedAt == nil {
		return nil, fmt.Errorf("comment updated at was nil: %+v", comment)
	}

	wrappedUser, err := c.wrapUser(comment.User)
	if err != nil {
		return nil, err
	}

	wrapped := &IssueComment{
		ID:        *comment.ID,
		User:      wrappedUser,
		Body:      *comment.Body,
		CreatedAt: *comment.CreatedAt,
		UpdatedAt: *comment.UpdatedAt,
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

func (c *client) PostIssueComment(owner, repo string, number int, comment *IssueReplyComment) error {
	if comment.Context == nil {
		return errors.New("comment context was nil")
	}

	contextStr, err := buildHiddenContextString(comment.Context)
	if err != nil {
		return err
	}

	comments, err := c.GetIssueComments(owner, repo, number)
	if err != nil {
		return err
	}

	ghComment := &gogithub.IssueComment{
		Body: String(fmt.Sprintf("%s\n%s", contextStr, comment.Body)),
	}

	// Attempt to find an existing comment by our user that matches the context
	for _, comment := range comments {
		if comment.User.Login != c.username {
			// Comment is not written by us
			continue
		}

		if comment.Body == *ghComment.Body {
			// Comments are already identical (including context),
			// nothing to do
			return nil
		} else if strings.HasPrefix(comment.Body, contextStr) {
			// Matches context, but body differs. Edit.
			_, _, err := c.gh.Issues.EditComment(owner, repo, number, ghComment)
			return err
		}
	}

	// No existing comment found or no context provided. Create a new one.
	_, _, err = c.gh.Issues.CreateComment(owner, repo, number, ghComment)
	return err
}

func buildHiddenContextString(context interface{}) (string, error) {
	contextJSON, err := json.Marshal(context)
	if err != nil {
		return "", err
	}

	return fmt.Sprintf("<!-- %s -->", contextJSON), nil
}
