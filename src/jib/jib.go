package jib

import (
	"jib/github"
	"log"
)

const (
	complianceStatusContext = "compliance"
)

type PullRequestHandler func(gh github.Client, pr *github.PullRequest) error

func InfoHandler(gh github.Client, pr *github.PullRequest) error {
	log.Printf("processing %s/%s#%d titled '%s'\n", pr.Owner, pr.Repository, pr.Number, pr.Title)
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
