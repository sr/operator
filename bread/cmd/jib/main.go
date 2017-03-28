package main

import (
	"errors"
	"flag"
	"fmt"
	"log"
	"net/http"
	"net/url"
	"os"
	"regexp"
	"strings"
	"sync"
	"time"

	"git.dev.pardot.com/Pardot/infrastructure/bread/jib"
	"git.dev.pardot.com/Pardot/infrastructure/bread/jib/github"
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
	pollDuration   time.Duration
	parallelism    int
	jib            *jib.Config
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
		jib: &jib.Config{
			ComplianceStatusContext:        "compliance",
			CIUserLogin:                    "sa-bamboo",
			CIAutomatedMergeMessageMatcher: regexp.MustCompile(`\A\[ci\] Automated branch merge`),
			StaleMaxAge:                    24 * 60 * time.Hour,
			EmergencyMergeAuthorizedTeams: []string{
				"app-on-call",
				"customer-centric-engineering",
				"engineering-managers",
				"site-reliability-engineers",
			},
		},
	}
	flags := flag.CommandLine
	flags.IntVar(&config.port, "port", 8080, "Listen port for the web service")
	flags.Var(&urlFlag{URL: config.githubBaseURL}, "github-base-url", "Base URL for the GitHub API")
	flags.StringVar(&config.githubUser, "github-user", "", "GitHub username")
	flags.StringVar(&config.githubAPIToken, "github-api-token", "", "GitHub API token")
	flags.StringVar(&config.githubOrg, "github-org", "", "GitHub organization name")
	flags.IntVar(&config.parallelism, "parallelism", 15, "Number of parallel threads of execution")
	flags.DurationVar(&config.pollDuration, "poll-duration", 30*time.Second, "Duration between polls of open pull requests")
	flags.DurationVar(&config.jib.StaleMaxAge, "stale-max-age", config.jib.StaleMaxAge, "Duration without an update after which pull requests are considered stale")
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

	gh := github.NewClient(config.githubBaseURL, config.githubUser, config.githubAPIToken)
	jibServer := jib.New(log.New(os.Stdout, "", log.LstdFlags), gh, config.jib)
	handlers := []jib.PullRequestHandler{
		jibServer.Info,
		jibServer.Fork,
		jibServer.Stale,
		jibServer.Merge,
		jibServer.Notify,
	}

	// TODO(alindeman): Implement a real webhook server
	server := &http.Server{
		Addr:    fmt.Sprintf(":%d", config.port),
		Handler: http.NotFoundHandler(),
	}
	go func() { panic(server.ListenAndServe()) }()

	for {
		openPRs, err := gh.GetOpenPullRequests(config.githubOrg)
		if err != nil {
			// TODO(alindeman): report to sentry
			fmt.Fprintf(os.Stderr, "error fetching open PRs, will retry: %v\n", err)
		} else {
			prC := make(chan *github.PullRequest)
			var wg sync.WaitGroup
			for i := 0; i < config.parallelism; i++ {
				wg.Add(1)
				go func() {
					for pr := range prC {
						for _, handler := range handlers {
							if err := handler(pr); err != nil {
								// An error in a handler is worrisome, but not fatal
								// TODO(alindeman): report to sentry
								fmt.Fprintf(os.Stderr, "error in %v handler: %v\n", handler, err)
							}
						}
					}
					wg.Done()
				}()
			}

			for _, pr := range openPRs {
				prC <- pr
			}
			close(prC)
			wg.Wait()
		}

		<-time.After(config.pollDuration)
	}
}
