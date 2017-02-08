package jib

import (
	"bytes"
	"html/template"
	"jib/github"
	"log"
	"regexp"
)

const (
	ComplianceStatusContext = "compliance"

	CIUserLogin = "sa-bamboo"
)

var (
	CIAutomatedMergeMessageMatcher = regexp.MustCompile(`\A\[ci\] Automated branch merge`)
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

func filterCIAutomatedMerges(commits []*github.Commit) []*github.Commit {
	filtered := []*github.Commit{}
	for _, commit := range commits {
		if commit.Author == nil || commit.Author.Login != CIUserLogin || !CIAutomatedMergeMessageMatcher.MatchString(commit.Message) {
			filtered = append(filtered, commit)
		}
	}
	return filtered
}
