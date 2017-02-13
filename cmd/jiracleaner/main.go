package main

import (
	"bytes"
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"strings"
	"time"

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
	if username == "" {
		return errors.New("required flag missing: username")
	}
	if password == "" {
		return errors.New("required flag missing: password")
	}
	transport := github.BasicAuthTransport{Username: username, Password: password}
	client := transport.Client()
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
	b, err := json.Marshal(data)
	if err != nil {
		return err
	}
	req, _ := http.NewRequest("POST", jiraURL+"/rest/api/2/search", bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")
	resp, err := client.Do(req)
	if err != nil {
		return err
	}
	defer func() { _ = resp.Body.Close() }()
	if resp.StatusCode != 200 {
		return fmt.Errorf("jira search request failed with status %d", resp.StatusCode)
	}
	type response struct {
		Issues []struct {
			ID     string `json:"id"`
			Key    string `json:"key"`
			Fields struct {
				Updated string `json:"updated"`
				Summary string `json:"summary"`
			} `json:"fields"`
		}
	}
	var results response
	if err := json.NewDecoder(resp.Body).Decode(&results); err != nil {
		return err
	}
	for _, issue := range results.Issues {
		fmt.Printf("%s %s %s\n",
			strings.Split(issue.Fields.Updated, "T")[0],
			fmt.Sprintf("%s/browse/%s", jiraURL, issue.Key),
			issue.Fields.Summary,
		)
		if apply {
			req, err := http.NewRequest("POST", jiraURL+"/rest/api/2/issue/"+issue.ID+"/transitions", nil)
			req.Header.Set("Content-Type", "application/json")
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
			if _, err := client.Do(req); err != nil {
				return fmt.Errorf("failed to close issue: %v", err)
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
