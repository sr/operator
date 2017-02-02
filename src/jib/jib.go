package jib

import (
	"jib/github"
	"log"
)

const (
	complianceStatusContext = "compliance"
)

type PullRequestHandler func(log *log.Logger, gh github.Client, pr *github.PullRequest) error

func InfoHandler(log *log.Logger, gh github.Client, pr *github.PullRequest) error {
	log.Printf("processing %s/%s#%d titled '%s'\n", pr.Org, pr.Repository, pr.Number, pr.Title)
	return nil
}

func findComplianceStatus(statuses []*github.CommitStatus) *github.CommitStatus {
	for _, status := range statuses {
		if status.Context == complianceStatusContext {
			return status
		}
	}

	return nil
}
