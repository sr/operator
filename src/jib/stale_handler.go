package jib

import (
	"html/template"
	"jib/github"
	"log"
	"strings"
	"time"
)

type StaleReplyCommentContext struct {
}

var (
	// Without an update in this duration, pull requests are considered stale
	staleDuration = 24 * 60 * time.Hour

	stalePrReply = template.Must(template.New("").Parse(strings.TrimSpace(`
@{{.User.Login}} In an effort to keep our list of open pull requests reasonable, I have started automatically closing stale pull requests.

Please feel free to reopen this pull request if it is still relevant.
`)))
)

func StaleHandler(log *log.Logger, gh github.Client, pr *github.PullRequest) error {
	if pr.State != github.StateOpen {
		// PR is not open; nothing to do
		return nil
	} else if time.Now().Sub(pr.UpdatedAt) < staleDuration {
		// PR is not stale; nothing to do
		return nil
	}

	log.Printf("closing stale pull request '%s'", pr)

	body, err := renderTemplate(stalePrReply, pr)
	if err != nil {
		return err
	}

	comment := &github.IssueReplyComment{
		Context: &StaleReplyCommentContext{},
		Body:    body,
	}

	err = gh.CloseIssue(pr.Org, pr.Repository, pr.Number)
	if err != nil {
		return err
	}

	err = gh.PostIssueComment(pr.Org, pr.Repository, pr.Number, comment)
	if err != nil {
		return err
	}

	return nil
}
