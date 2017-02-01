package main

import (
	"errors"
	"fmt"
	"jib"
	"jib/github"
	"net/url"
	"os"
	"strings"
)

func main() {
	if err := run(); err != nil {
		fmt.Fprintf(os.Stderr, "%s: %v\n", os.Args[0], err)
		os.Exit(1)
	}
}

func run() error {
	port := os.Getenv("PORT")
	if port == "" {
		return errors.New("PORT environment variable is required")
	}

	baseURLStr := os.Getenv("GITHUB_URL")
	if baseURLStr == "" {
		baseURLStr = "https://git.dev.pardot.com/api/v3/"
	}

	baseURL, err := url.Parse(baseURLStr)
	if err != nil {
		return fmt.Errorf("unable to parse GitHub URL '%s': %v", baseURLStr, err)
	}

	githubUser := os.Getenv("GITHUB_USER")
	if githubUser == "" {
		return errors.New("GITHUB_USER environment variable is required")
	}

	githubAPIToken := os.Getenv("GITHUB_API_TOKEN")
	if githubAPIToken == "" {
		return errors.New("GITHUB_API_TOKEN environment variable is required")
	}

	githubRepositoriesStr := os.Getenv("GITHUB_REPOSITORIES")
	if githubRepositoriesStr == "" {
		return errors.New("GITHUB_REPOSITORIES environment variable is required in the form 'org1/repo1,org2/repo2,...'")
	}

	repositories := strings.Split(githubRepositoriesStr, ",")
	gh := github.NewClient(baseURL, githubUser, githubAPIToken)

	handlers := []jib.PullRequestHandler{
		jib.InfoHandler,
		jib.MergeCommandHandler,
	}

	for _, repository := range repositories {
		parts := strings.SplitN(repository, "/", 2)
		if len(parts) != 2 {
			return fmt.Errorf("expected repository name '%s' to be in the form 'org/name', but was not", repository)
		}

		org := parts[0]
		repo := parts[1]

		openPRs, err := gh.GetOpenPullRequests(org, repo)
		if err != nil {
			return err
		}

		for _, pr := range openPRs {
			for _, handler := range handlers {
				err := handler(gh, pr)
				if err != nil {
					// An error in a handler is worrisome, but not fatal
					// TODO(alindeman): report to sentry
					fmt.Fprintf(os.Stderr, "error in %v handler: %v\n", handler, err)
				}
			}
		}
	}

	return nil
}
