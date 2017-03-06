package jira

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"net/url"
	"strings"

	"golang.org/x/net/context/ctxhttp"

	"github.com/google/go-github/github"
)

type Issue struct {
	ID     string  `json:"id,omitempty"`
	Key    string  `json:"key,omitempty"`
	Self   string  `json:"self,omitempty"`
	Fields *Fields `json:"fields,omitempty"`
}

func (i *Issue) HTMLURL() string {
	if i.Self == "" {
		return ""
	}
	parsed, err := url.Parse(i.Self)
	if err != nil {
		return ""
	}
	parsed.Path = fmt.Sprintf("/browse/%s", i.Key)
	return parsed.String()
}

func (i *Issue) GetAssigneeKey() string {
	if i == nil || i.Fields == nil || i.Fields.Assignee == nil {
		return ""
	}
	return i.Fields.Assignee.Key
}

func (i *Issue) StatusName() string {
	if i == nil || i.Fields == nil || i.Fields.Status == nil {
		return ""
	}
	return i.Fields.Status.Name
}

type Fields struct {
	Project     *Project     `json:"project,omitempty"`
	IssueType   *IssueType   `json:"issue_type,omitempty"`
	Updated     string       `json:"updated,omitempty"`
	Summary     string       `json:"summary,omitempty"`
	Description string       `json:"description,omitempty"`
	Status      *IssueStatus `json:"status,omitempty"`
	Assignee    *User        `json:"assignee,omitempty"`
}

type User struct {
	Key         string `json:"key,omitempty"`
	Name        string `json:"name,omitempty"`
	DisplayName string `json:"displayName,omitempty"`
}

type Project struct {
	Key string `json:"key,omitempty"`
}

type IssueType struct {
	Name string `json:"name,omitempty"`
}

type IssueStatus struct {
	Name string `json:"name,omitempty"`
}

type Client interface {
	Search(ctx context.Context, query string, fields []string, maxResults int) ([]*Issue, error)
	Close(ctx context.Context, issueID string, transitionID int, resolution string, comment string) error
}

type client struct {
	baseURL string
	http    *http.Client
}

func NewClient(baseURL string, username, password string) Client {
	tr := github.BasicAuthTransport{Username: username, Password: password}
	return &client{baseURL, tr.Client()}
}

func (c *client) Search(ctx context.Context, query string, fields []string, maxResults int) ([]*Issue, error) {
	if maxResults == 0 {
		maxResults = 100
	}
	data := struct {
		JQL        string   `json:"jql"`
		Fields     []string `json:"fields"`
		MaxResults int      `json:"maxResults"`
	}{
		query,
		fields,
		maxResults,
	}
	body, err := json.Marshal(data)
	if err != nil {
		return nil, err
	}
	req, _ := http.NewRequest("POST", c.baseURL+"/rest/api/2/search", bytes.NewReader(body))
	resp, err := c.do(ctx, req, 200)
	if err != nil {
		return nil, err
	}
	defer func() { _ = resp.Body.Close() }()
	type response struct{ Issues []*Issue }
	var results response
	if err := json.NewDecoder(resp.Body).Decode(&results); err != nil {
		return nil, err
	}
	return results.Issues, nil
}

func (c *client) Close(ctx context.Context, issueID string, transitionID int, resolution string, comment string) error {
	req, err := http.NewRequest("POST", c.baseURL+"/rest/api/2/issue/"+issueID+"/transitions", ioutil.NopCloser(strings.NewReader(fmt.Sprintf(`{
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
				"name": "%s"
			}
		},
		"transition": {
			"id": "%d"
		}
	}`, comment, resolution, transitionID))))
	if err != nil {
		return err
	}
	_, err = c.do(ctx, req, 204)
	return err
}

func (c *client) do(ctx context.Context, req *http.Request, expectedStatus int) (*http.Response, error) {
	if req.Body != nil {
		req.Header.Set("Content-Type", "application/json")
	}
	resp, err := ctxhttp.Do(ctx, c.http, req)
	if err != nil {
		return resp, err
	}
	if resp.StatusCode != expectedStatus {
		return resp, fmt.Errorf("expected status 204, got %d", resp.StatusCode)
	}
	return resp, err
}
