package github

import (
	"fmt"
	"time"
)

type FakeClient struct {
	ProvidedUsername string
	OpenPullRequests []*PullRequest
	IssueComments    map[int][]*IssueComment
	PermissionLevels map[string]PermissionLevel
	CommitStatuses   map[string][]*CommitStatus
	CommitsSince     map[string][]*Commit

	MergedPullRequests map[int]string
	PostedComments     []*IssueReplyComment
	ClosedIssues       []int
}

// Ensure FakeClient conforms to the GithubClient interface
var _ Client = &FakeClient{}

func (c *FakeClient) Username() string {
	return c.ProvidedUsername
}

func (c *FakeClient) GetOpenPullRequests(org string) ([]*PullRequest, error) {
	return c.OpenPullRequests, nil
}

func (c *FakeClient) GetIssueComments(org, repo string, number int) ([]*IssueComment, error) {
	if comments, ok := c.IssueComments[number]; ok {
		return comments, nil
	} else {
		return nil, fmt.Errorf("no pull request comments defined for %s/%s#%d", org, repo, number)
	}
}

func (c *FakeClient) GetUserPermissionLevel(org, repo, login string) (PermissionLevel, error) {
	if permissionLevel, ok := c.PermissionLevels[login]; ok {
		return permissionLevel, nil
	} else {
		return "", fmt.Errorf("no permission level defined for %s", login)
	}
}

func (c *FakeClient) MergePullRequest(org, repo string, number int, commitMessage string) error {
	if c.MergedPullRequests == nil {
		c.MergedPullRequests = map[int]string{}
	}
	c.MergedPullRequests[number] = commitMessage

	return nil
}

func (c *FakeClient) GetCommitStatuses(org, repo, ref string) ([]*CommitStatus, error) {
	if statuses, ok := c.CommitStatuses[ref]; ok {
		return statuses, nil
	} else {
		return nil, fmt.Errorf("no commit statuses for %s", ref)
	}
}

func (c *FakeClient) GetCommitsSince(org, repo, sha string, since time.Time) ([]*Commit, error) {
	if commits, ok := c.CommitsSince[sha]; ok {
		return commits, nil
	} else {
		return nil, fmt.Errorf("no commits since for %s", sha)
	}
}

func (c *FakeClient) PostIssueComment(org, repo string, number int, comment *IssueReplyComment) error {
	c.PostedComments = append(c.PostedComments, comment)
	return nil
}

func (c *FakeClient) CloseIssue(org, repo string, number int) error {
	c.ClosedIssues = append(c.ClosedIssues, number)
	return nil
}
