package main

import (
	"context"
	"errors"
	"flag"
	"fmt"
	"os"
	"strings"
	"time"

	"git.dev.pardot.com/Pardot/bread/jira"
)

const (
	defaultJIRAURL      = "https://jira.dev.pardot.com"
	defaultProject      = "BREAD"
	query               = `project = '%s' AND (updatedDate <= "%s" OR updatedDate IS EMPTY) AND status NOT IN (Closed, "Will Not Do", Resolved) ORDER BY updatedDate ASC`
	defaultTransitionID = 2
	defaultResolution   = "Won't Fix"
)

var (
	apply        bool
	jiraURL      string
	maxAge       time.Duration
	project      string
	username     string
	password     string
	transitionID int
	resolution   string

	defaultMaxAge = (time.Hour * 24) * 30 * 3
	comment       = strings.Replace(`In an effort to keep our backlog realistic and up to date we have decided to automatically close stale tickets.

Please feel free to reopen or talk to us it if you think it should be prioritized.

Thanks,

The BREAD team`, "\n", "\\n", -1)
)

func run() error {
	flag.BoolVar(&apply, "apply", false, "Close tickets for real")
	flag.StringVar(&jiraURL, "jira-url", defaultJIRAURL, "URL of the JIRA installation.")
	flag.StringVar(&project, "project", defaultProject, "Key of the project to manage")
	flag.DurationVar(&maxAge, "max-age", defaultMaxAge, "Tickets that have not been in updated in this many hours are automatically closed")
	flag.StringVar(&username, "username", "", "JIRA username")
	flag.StringVar(&password, "password", "", "JIRA password")
	flag.IntVar(&transitionID, "transition-id", defaultTransitionID, "Transition ID for closing stale tickets")
	flag.StringVar(&resolution, "resolution", defaultResolution, "Resolution to use for closing stale tickets")
	flag.Parse()
	if username == "" {
		return errors.New("required flag missing: username")
	}
	if password == "" {
		return errors.New("required flag missing: password")
	}
	client := jira.NewClient(jiraURL, username, password)
	now := time.Now()
	cutOff := now.Add(-maxAge)
	issues, err := client.Search(
		context.TODO(),
		fmt.Sprintf(query, project, cutOff.Format("2006-01-02")),
		[]string{"id", "key", "created", "updated", "summary"},
		100,
	)
	if err != nil {
		return err
	}
	for _, issue := range issues {
		fmt.Printf("%s %s %s\n",
			strings.Split(issue.Fields.Updated, "T")[0],
			fmt.Sprintf("%s/browse/%s", jiraURL, issue.Key),
			issue.Fields.Summary,
		)
		if apply {
			if err := client.Close(context.TODO(), issue.ID, transitionID, resolution, comment); err != nil {
				return fmt.Errorf("failed to close %s: %v", issue.Key, err)
			}
		}
	}
	return nil
}

func main() {
	if err := run(); err != nil {
		fmt.Fprintf(os.Stderr, "jiracleaner: %v\n", err)
		os.Exit(1)
	}
	os.Exit(0)
}
