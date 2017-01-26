package heroku

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
)

type Source struct {
	SourceBlob *SourceSourceBlob `json:"source_blob"`
}

type SourceSourceBlob struct {
	GetURL string `json:"get_url"`
	PutURL string `json:"put_url"`
}

type Build struct {
	ID         string           `json:"id"`
	SourceBlob *BuildSourceBlob `json:"source_blob"`
}

type BuildSourceBlob struct {
	URL     string `json:"url"`
	Version string `json:"version"`
}

type Client struct {
	APIToken string
	HTTP     *http.Client
}

func NewClient(apiToken string) *Client {
	return &Client{
		APIToken: apiToken,
		HTTP:     &http.Client{},
	}
}

func (c *Client) CreateSource(app string) (*Source, error) {
	req, err := c.newRequest("POST", fmt.Sprintf("/apps/%s/sources", app), nil)
	if err != nil {
		return nil, err
	}

	source := new(Source)
	err = c.do(req, source)
	if err != nil {
		return nil, err
	}
	return source, nil
}

func (c *Client) CreateBuild(app string, build *Build) (*Build, error) {
	req, err := c.newRequest("POST", fmt.Sprintf("/apps/%s/builds", app), build)
	if err != nil {
		return nil, err
	}

	b := new(Build)
	err = c.do(req, b)
	if err != nil {
		return nil, err
	}
	return b, nil
}

func (c *Client) do(req *http.Request, v interface{}) error {
	resp, err := c.HTTP.Do(req)
	if err != nil {
		return err
	} else if resp.StatusCode < 200 || resp.StatusCode > 299 {
		return fmt.Errorf("HTTP %d for %s %s", resp.StatusCode, req.Method, req.URL)
	}
	defer func() { _ = resp.Body.Close() }()

	return json.NewDecoder(resp.Body).Decode(v)
}

func (c *Client) newRequest(method string, path string, body interface{}) (*http.Request, error) {
	var buf io.ReadWriter
	if body != nil {
		buf = new(bytes.Buffer)
		err := json.NewEncoder(buf).Encode(body)
		if err != nil {
			return nil, err
		}
	}

	req, err := http.NewRequest(method, fmt.Sprintf("https://api.heroku.com%s", path), buf)
	if err != nil {
		return nil, err
	}
	req.Header.Set("accept", "application/vnd.heroku+json; version=3")
	req.Header.Set("authorization", fmt.Sprintf("Bearer %s", c.APIToken))

	return req, nil
}
