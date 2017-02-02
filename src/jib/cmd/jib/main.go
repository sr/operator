package main

import (
	"errors"
	"flag"
	"fmt"
	"jib"
	"jib/github"
	"log"
	"net/url"
	"os"
	"strings"
)

type urlFlag struct {
	URL *url.URL
}

func (f *urlFlag) Set(s string) error {
	url, err := url.Parse(s)
	if err != nil {
		return err
	}

	*f.URL = *url
	return nil
}
func (f *urlFlag) String() string {
	if f.URL == nil {
		return ""
	}
	return f.URL.String()
}

type config struct {
	port           int
	githubBaseURL  *url.URL
	githubUser     string
	githubAPIToken string
	githubOrg      string
}

func main() {
	if err := run(); err != nil {
		fmt.Fprintf(os.Stderr, "%s: %v\n", os.Args[0], err)
		os.Exit(1)
	}
}

func run() error {
	config := &config{
		githubBaseURL: &url.URL{
			Scheme: "https",
			Host:   "git.dev.pardot.com",
			Path:   "/api/v3/",
		},
	}
	flags := flag.CommandLine
	flags.IntVar(&config.port, "port", 8080, "Listen port for the web service")
	flags.Var(&urlFlag{URL: config.githubBaseURL}, "github-base-url", "Base URL for the GitHub API")
	flags.StringVar(&config.githubUser, "github-user", "", "GitHub username")
	flags.StringVar(&config.githubAPIToken, "github-api-token", "", "GitHub API token")
	flags.StringVar(&config.githubOrg, "github-org", "", "GitHub organization name")
	// Allow setting flags via environment variables
	flags.VisitAll(func(f *flag.Flag) {
		k := strings.ToUpper(strings.Replace(f.Name, "-", "_", -1))
		if v := os.Getenv(k); v != "" {
			if err := f.Value.Set(v); err != nil {
				panic(err)
			}
		}
	})

	if err := flags.Parse(os.Args[1:]); err != nil {
		return err
	}
	if config.githubUser == "" {
		return errors.New("required flag missing: github-user")
	} else if config.githubAPIToken == "" {
		return errors.New("required flag missing: github-api-token")
	} else if config.githubOrg == "" {
		return errors.New("required flag missing: github-org")
	} else if config.githubBaseURL == nil {
		return errors.New("required flag missing: github-base-url")
	}

	handlers := []jib.PullRequestHandler{
		jib.InfoHandler,
		jib.MergeCommandHandler,
	}
	log := log.New(os.Stdout, "", log.LstdFlags)

	gh := github.NewClient(config.githubBaseURL, config.githubUser, config.githubAPIToken)
	openPRs, err := gh.GetOpenPullRequests(config.githubOrg)
	if err != nil {
		return err
	}

	for _, pr := range openPRs {
		for _, handler := range handlers {
			err := handler(log, gh, pr)
			if err != nil {
				// An error in a handler is worrisome, but not fatal
				// TODO(alindeman): report to sentry
				fmt.Fprintf(os.Stderr, "error in %v handler: %v\n", handler, err)
			}
		}
	}

	return nil
}
