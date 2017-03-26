package jib

import (
	"bytes"
	"html/template"
	"log"
	"regexp"
	"time"

	"git.dev.pardot.com/Pardot/infrastructure/bread/jib/github"
)

type Server struct {
	log    *log.Logger
	gh     github.Client
	config *Config
}

type Config struct {
	ComplianceStatusContext        string
	CIUserLogin                    string
	CIAutomatedMergeMessageMatcher *regexp.Regexp
	StaleMaxAge                    time.Duration
	EmergencyMergeAuthorizedTeams  []string
}

type PullRequestHandler func(pr *github.PullRequest) error

func New(log *log.Logger, gh github.Client, config *Config) *Server {
	if config == nil {
		config = &Config{}
	}
	return &Server{log, gh, config}
}

func (s *Server) Info(pr *github.PullRequest) error {
	s.log.Printf("processing %s/%s#%d titled '%s'\n", pr.Org, pr.Repository, pr.Number, pr.Title)
	return nil
}

func (s *Server) findComplianceStatus(statuses []*github.CommitStatus) *github.CommitStatus {
	for _, status := range statuses {
		if status.Context == s.config.ComplianceStatusContext {
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

func (s *Server) filterCIAutomatedMerges(commits []*github.Commit) []*github.Commit {
	if s.config.CIAutomatedMergeMessageMatcher == nil {
		return commits
	}
	filtered := []*github.Commit{}
	for _, commit := range commits {
		if commit.Author == nil || commit.Author.Login != s.config.CIUserLogin || !s.config.CIAutomatedMergeMessageMatcher.MatchString(commit.Message) {
			filtered = append(filtered, commit)
		}
	}
	return filtered
}
