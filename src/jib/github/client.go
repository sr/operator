package github

import (
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"net/url"
	"strings"
	"time"

	gogithub "github.com/google/go-github/github"
)

const (
	githubMaxPerPage = 100
)

type Repository struct {
	Org  string
	Name string
}

type PullRequest struct {
	Org        string
	Repository string
	Number     int

	User *User

	State string
	Title string

	UpdatedAt time.Time

	HeadSHA string

	// Mergeable is either true (mergeable), false (not mergeable), or null (not computed yet)
	Mergeable *bool
}

const (
	IssueStateOpen   string = "open"
	IssueStateClosed string = "closed"
)

func (p *PullRequest) String() string {
	return fmt.Sprintf("%s/%s#%d \"%s\"", p.Org, p.Repository, p.Number, p.Title)

}

type IssueComment struct {
	ID   int
	User *User
	Body string

	CreatedAt time.Time
	UpdatedAt time.Time
}

// IssueReplyComment represents the bot's reply to a given command or other
// event. It is meant to be idempotent and updatable
type IssueReplyComment struct {
	// Replies with the same Context will be updated instead of posted anew.
	//
	// Context must be serializable to JSON.
	Context interface{}

	Body string
}

type User struct {
	Login string
}

type PermissionLevel string

var (
	PermissionLevelAdmin PermissionLevel = "admin"
	PermissionLevelWrite PermissionLevel = "write"
)

type CommitStatusState string

type CommitStatus struct {
	Context string
	State   CommitStatusState
}

var (
	CommitStatusFailure CommitStatusState = "failure"
	CommitStatusPending CommitStatusState = "pending"
	CommitStatusSuccess CommitStatusState = "success"
)

type Commit struct {
	SHA       string
	Message   string
	Author    *User
	Committer *User
}

type Team struct {
	ID   int
	Name string
	Slug string
}

func Bool(b bool) *bool {
	return &b
}

func String(s string) *string {
	return &s
}

// Client is a pared-down version of the GitHub client from
// github.com/google/go-github, focusing on higher-level, safe or otherwise
// idempotent operations
type Client interface {
	Username() string
	GetOpenPullRequests(org string) ([]*PullRequest, error)
	GetIssueComments(org, repo string, number int) ([]*IssueComment, error)
	GetUserPermissionLevel(org, repo, login string) (PermissionLevel, error)
	GetCommitStatuses(org, repo, ref string) ([]*CommitStatus, error)
	GetCommitsSince(org, repo, sha string, since time.Time) ([]*Commit, error)
	GetUserTeams(org, login string) ([]*Team, error)

	MergePullRequest(org, repo string, number int, commitMessage string) error
	PostIssueComment(org, repo string, number int, comment *IssueReplyComment) error
	CloseIssue(org, repo string, number int) error
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

func (c *client) GetOpenPullRequests(org string) ([]*PullRequest, error) {
	opt := &gogithub.IssueListOptions{
		Filter:    "all",
		State:     "open",
		Sort:      "created",
		Direction: "desc",
		ListOptions: gogithub.ListOptions{
			PerPage: githubMaxPerPage,
		},
	}

	allPullRequests := []*PullRequest{}
	for {
		issues, resp, err := c.gh.Issues.ListByOrg(org, opt)
		if err != nil {
			return nil, err
		}

		for _, issue := range issues {
			if issue.PullRequestLinks == nil {
				// Issue is not a pull request, just a generic issue
				continue
			} else if issue.Number == nil {
				continue
			} else if issue.Repository == nil {
				continue
			}

			// Refetching the pull request from the individual route
			// is required to get mergeability
			fullPullRequest, _, err := c.gh.PullRequests.Get(org, *issue.Repository.Name, *issue.Number)
			if err != nil {
				return nil, err
			}

			wrapped, err := wrapPullRequest(org, *issue.Repository.Name, fullPullRequest)
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

func (c *client) GetIssueComments(org, repo string, number int) ([]*IssueComment, error) {
	opt := &gogithub.IssueListCommentsOptions{
		ListOptions: gogithub.ListOptions{
			PerPage: githubMaxPerPage,
		},
	}

	allComments := []*IssueComment{}
	for {
		comments, resp, err := c.gh.Issues.ListComments(org, repo, number, opt)
		if err != nil {
			return nil, err
		}

		for _, comment := range comments {
			wrapped, err := wrapIssueComment(comment)
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

func (c *client) GetUserPermissionLevel(org, repo, login string) (PermissionLevel, error) {
	rpl, _, err := c.gh.Repositories.GetPermissionLevel(org, repo, login)
	if err != nil {
		return "", err
	} else if rpl.Permission == nil {
		return "", fmt.Errorf("permission was nil: %+v", rpl)
	}

	return PermissionLevel(*rpl.Permission), nil
}

func (c *client) GetCommitsSince(org, repo, sha string, since time.Time) ([]*Commit, error) {
	opt := &gogithub.CommitsListOptions{
		SHA:   sha,
		Since: since,
		ListOptions: gogithub.ListOptions{
			PerPage: githubMaxPerPage,
		},
	}

	allCommits := []*Commit{}
	for {
		commits, resp, err := c.gh.Repositories.ListCommits(org, repo, opt)
		if err != nil {
			return nil, err
		}

		for _, commit := range commits {
			wrapped, err := wrapCommit(commit)
			if err != nil {
				return nil, err
			}

			allCommits = append(allCommits, wrapped)
		}

		if resp.NextPage == 0 {
			break
		}
		opt.ListOptions.Page = resp.NextPage
	}

	return allCommits, nil
}

func (c *client) GetUserTeams(org, login string) ([]*Team, error) {
	opt := &gogithub.ListOptions{
		PerPage: githubMaxPerPage,
	}

	allTeams := []*Team{}
	for {
		teams, resp, err := c.gh.Organizations.ListUserTeams(opt)
		if err != nil {
			return nil, err
		}

		for _, team := range teams {
			wrapped, err := wrapTeam(team)
			if err != nil {
				return nil, err
			}

			allTeams = append(allTeams, wrapped)
		}

		if resp.NextPage == 0 {
			break
		}
		opt.Page = resp.NextPage
	}

	return allTeams, nil
}

func (c *client) MergePullRequest(org, repo string, number int, commitMessage string) error {
	opt := &gogithub.PullRequestOptions{}
	_, _, err := c.gh.PullRequests.Merge(org, repo, number, commitMessage, opt)
	return err
}

func (c *client) PostIssueComment(org, repo string, number int, comment *IssueReplyComment) error {
	if comment.Context == nil {
		return errors.New("comment context was nil")
	}

	contextStr, err := buildHiddenContextString(comment.Context)
	if err != nil {
		return err
	}

	comments, err := c.GetIssueComments(org, repo, number)
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
			_, _, err := c.gh.Issues.EditComment(org, repo, number, ghComment)
			return err
		}
	}

	// No existing comment found or no context provided. Create a new one.
	_, _, err = c.gh.Issues.CreateComment(org, repo, number, ghComment)
	return err
}

func (c *client) GetCommitStatuses(org, repo, ref string) ([]*CommitStatus, error) {
	opt := &gogithub.ListOptions{
		PerPage: githubMaxPerPage,
	}

	cs, _, err := c.gh.Repositories.GetCombinedStatus(org, repo, ref, opt)
	if err != nil {
		return nil, err
	}

	statuses := []*CommitStatus{}
	for _, ghStatus := range cs.Statuses {
		status, err := wrapCommitStatus(&ghStatus)
		if err != nil {
			return nil, err
		}

		statuses = append(statuses, status)
	}

	return statuses, nil
}

func (c *client) CloseIssue(org, repo string, number int) error {
	req := &gogithub.IssueRequest{
		State: gogithub.String("closed"),
	}

	_, _, err := c.gh.Issues.Edit(org, repo, number, req)
	return err
}

func wrapRepository(org string, repository *gogithub.Repository) (*Repository, error) {
	if repository.Name == nil {
		return nil, fmt.Errorf("repository name was nil: %+v", repository)
	}

	wrapped := &Repository{
		Org:  org,
		Name: *repository.Name,
	}
	return wrapped, nil
}

func wrapCommitStatus(status *gogithub.RepoStatus) (*CommitStatus, error) {
	if status.State == nil {
		return nil, fmt.Errorf("status state was nil: %+v", status)
	} else if status.Context == nil {
		return nil, fmt.Errorf("status context was nil: %+v", status)
	}

	wrapped := &CommitStatus{
		Context: *status.Context,
		State:   CommitStatusState(*status.State),
	}
	return wrapped, nil
}

func wrapPullRequest(org, repo string, pullRequest *gogithub.PullRequest) (*PullRequest, error) {
	if pullRequest.Number == nil {
		return nil, fmt.Errorf("pull request number was nil: %+v", pullRequest)
	} else if pullRequest.State == nil {
		return nil, fmt.Errorf("pull request state was nil: %+v", pullRequest)
	} else if pullRequest.Title == nil {
		return nil, fmt.Errorf("pull request title was nil: %+v", pullRequest)
	} else if pullRequest.UpdatedAt == nil {
		return nil, fmt.Errorf("pull request updated at was nil: %+v", pullRequest)
	} else if pullRequest.Head == nil {
		return nil, fmt.Errorf("pull request head was nil: %+v", pullRequest)
	} else if pullRequest.Head.SHA == nil {
		return nil, fmt.Errorf("pull request head SHA was nil: %+v", pullRequest)
	} else if pullRequest.User == nil {
		return nil, fmt.Errorf("pull request user was nil: %+v", pullRequest)
	}

	wrappedUser, err := wrapUser(pullRequest.User)
	if err != nil {
		return nil, err
	}

	wrapped := &PullRequest{
		Org:        org,
		Repository: repo,
		Number:     *pullRequest.Number,
		User:       wrappedUser,
		State:      *pullRequest.State,
		Title:      *pullRequest.Title,
		UpdatedAt:  *pullRequest.UpdatedAt,
		HeadSHA:    *pullRequest.Head.SHA,
		Mergeable:  pullRequest.Mergeable,
	}
	return wrapped, nil
}

func wrapIssueComment(comment *gogithub.IssueComment) (*IssueComment, error) {
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

	wrappedUser, err := wrapUser(comment.User)
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

func wrapUser(user *gogithub.User) (*User, error) {
	if user.Login == nil {
		return nil, fmt.Errorf("user Login was nil: %+v", user)
	}

	wrapped := &User{
		Login: *user.Login,
	}
	return wrapped, nil
}

func wrapCommit(commit *gogithub.RepositoryCommit) (*Commit, error) {
	if commit.SHA == nil {
		return nil, fmt.Errorf("commit sha was nil: %+v", commit)
	} else if commit.Commit == nil {
		return nil, fmt.Errorf("commit commit was nil: %+v", commit)
	} else if commit.Commit.Message == nil {
		return nil, fmt.Errorf("commit message was nil: %+v", commit.Commit)
	}

	// It is valid for author or committer to be nil, if they don't match
	// any known GitHub users
	var author, committer *User

	if commit.Author != nil {
		var err error
		author, err = wrapUser(commit.Author)
		if err != nil {
			return nil, err
		}
	}

	if commit.Committer != nil {
		var err error
		committer, err = wrapUser(commit.Committer)
		if err != nil {
			return nil, err
		}
	}

	wrapped := &Commit{
		SHA:       *commit.SHA,
		Message:   *commit.Commit.Message,
		Author:    author,
		Committer: committer,
	}
	return wrapped, nil
}

func wrapTeam(team *gogithub.Team) (*Team, error) {
	if team.ID == nil {
		return nil, fmt.Errorf("team.ID was nil: %+v", team)
	} else if team.Name == nil {
		return nil, fmt.Errorf("team.Name was nil: %+v", team)
	} else if team.Slug == nil {
		return nil, fmt.Errorf("team.Slug was nil: %+v", team)
	}

	wrapped := &Team{
		ID:   *team.ID,
		Name: *team.Name,
		Slug: *team.Slug,
	}
	return wrapped, nil
}

func buildHiddenContextString(context interface{}) (string, error) {
	contextJSON, err := json.Marshal(context)
	if err != nil {
		return "", err
	}

	return fmt.Sprintf("<!-- %s -->", contextJSON), nil
}
