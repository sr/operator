package main

import (
	"errors"
	"flag"
	"fmt"
	"io/ioutil"
	"os"
	"strings"
	"time"

	"github.com/andygrunwald/go-jira"
	"github.com/google/go-github/github"
)

const (
	defaultJIRAURL      = "https://jira.dev.pardot.com"
	defaultProject      = "BREAD"
	query               = `project = '%s' AND (updatedDate <= "%s" OR updatedDate IS EMPTY) AND status NOT IN (Closed, "Will Not Do", Resolved) ORDER BY updatedDate ASC`
	defaultTransitionID = 2
)

var (
	apply        bool
	jiraURL      string
	maxAge       time.Duration
	project      string
	username     string
	password     string
	transitionID int

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
	flag.Parse()
	if username == "" || password == "" {
		return errors.New("required flag missing: username, password")
	}
	transport := github.BasicAuthTransport{Username: username, Password: password}
	client, err := jira.NewClient(transport.Client(), jiraURL)
	if err != nil {
		return err
	}
	now := time.Now()
	cutOff := now.Add(-maxAge)
	data := struct {
		JQL        string   `json:"jql"`
		Fields     []string `json:"fields"`
		MaxResults int      `json:"maxResults"`
	}{
		fmt.Sprintf(query, project, cutOff.Format("2006-01-02")),
		[]string{"id", "key", "created", "updated", "summary"},
		100,
	}
	req, _ := client.NewRequest("POST", "/rest/api/2/search", &data)
	type response struct {
		Issues []jira.Issue
	}
	var results response
	if _, err = client.Do(req, &results); err != nil {
		return err
	}
	for _, issue := range results.Issues {
		fmt.Printf("%s %s %s\n",
			strings.Split(issue.Fields.Updated, "T")[0],
			fmt.Sprintf("%s/browse/%s", jiraURL, issue.Key),
			issue.Fields.Summary,
		)
		if apply {
			req, err := client.NewRequest("POST", "/rest/api/2/issue/"+issue.ID+"/transitions", nil)
			if err != nil {
				return err
			}
			req.Body = ioutil.NopCloser(strings.NewReader(fmt.Sprintf(`{
				"update": {
					"comment": [
						{
							"add": {
								"body": "%s"
							}
						}
					]
				},
				"fields": {
					"resolution": {
						"name": "Won't Fix"
					}
				},
				"transition": {
					"id": "%d"
				}
			}`, comment, transitionID)))
			if r, err := client.Do(req, nil); err != nil {
				s, e := ioutil.ReadAll(r.Body)
				if e != nil {
					return e
				}
				return fmt.Errorf("failed to close issue. body: %s", string(s))
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
