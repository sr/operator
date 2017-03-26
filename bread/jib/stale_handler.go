package jib

import (
	"html/template"
	"strings"
	"time"

	"git.dev.pardot.com/Pardot/infrastructure/bread/jib/github"
)

var (
	stalePrReply = template.Must(template.New("").Parse(strings.TrimSpace(`
@{{.User.Login}} In an effort to keep our list of open pull requests reasonable, I have started automatically closing stale pull requests.

Please feel free to reopen this pull request if it is still relevant.
`)))
)

func (s *Server) Stale(pr *github.PullRequest) error {
	if pr.State != github.IssueStateOpen {
		// PR is not open; nothing to do
		return nil
	} else if time.Now().Sub(pr.UpdatedAt) < s.config.StaleMaxAge {
		// PR is not stale; nothing to do
		return nil
	}

	s.log.Printf("closing stale pull request '%s'", pr)

	body, err := renderTemplate(stalePrReply, pr)
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
