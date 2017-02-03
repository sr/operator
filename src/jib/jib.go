package jib

import (
	"bytes"
	"html/template"
	"jib/github"
	"log"
)

const (
	ComplianceStatusContext = "compliance"
)

type PullRequestHandler func(log *log.Logger, gh github.Client, pr *github.PullRequest) error

func InfoHandler(log *log.Logger, gh github.Client, pr *github.PullRequest) error {
	log.Printf("processing %s/%s#%d titled '%s'\n", pr.Org, pr.Repository, pr.Number, pr.Title)
	return nil
}

func findComplianceStatus(statuses []*github.CommitStatus) *github.CommitStatus {
	for _, status := range statuses {
		if status.Context == ComplianceStatusContext {
			return status
		}
	}

	return nil
}

func renderTemplate(t *template.Template, context interface{}) (string, error) {
	buf := new(bytes.Buffer)

	err := t.Execute(buf, context)
	if err != nil {
		return "", err
	}
	return buf.String(), nil
}
