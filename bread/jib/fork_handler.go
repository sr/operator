package jib

import (
	"html/template"
	"strings"

	"git.dev.pardot.com/Pardot/infrastructure/bread/jib/github"
)

var (
	forkedPrReply = template.Must(template.New("").Parse(strings.TrimSpace(`
@{{.User.Login}} Due to a weakness in our Continuous Integration server, pull requests originating from forked repositories are not allowed because we cannot run tests against forked repositories.

Please push your code to a branch on the organization repository, then reopen the pull request against that branch.
`)))
)

func (s *Server) Fork(pr *github.PullRequest) error {
	if pr.State != github.IssueStateOpen {
		// PR is not open; nothing to do
		return nil
	} else if pr.HeadUser == pr.BaseUser {
		// PR head is not from a fork; nothing to do
		return nil
	}

	s.log.Printf("closing PR from a fork '%s'", pr)

	body, err := renderTemplate(forkedPrReply, pr)
	if err != nil {
		return err
	}

	comment := &github.IssueReplyComment{
		Context: struct{}{},
		Body:    body,
	}

	err = s.gh.CloseIssue(pr.Org, pr.Repository, pr.Number)
	if err != nil {
		return err
	}

	err = s.gh.PostIssueComment(pr.Org, pr.Repository, pr.Number, comment)
	if err != nil {
		return err
	}

	return nil
}
