package jib

import (
	"jib/github"
	"log"
)

type PullRequestHandler func(gh github.Client, pr *github.PullRequest) error

func InfoHandler(gh github.Client, pr *github.PullRequest) error {
	log.Printf("processing %s/%s#%d titled '%s'\n", pr.Owner, pr.Repository, pr.Number, pr.Title)
	return nil
}
