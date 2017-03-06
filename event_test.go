package bread_test

import (
	"crypto/hmac"
	"crypto/sha1"
	"encoding/hex"
	"io/ioutil"
	"log"
	"net/http"
	"net/http/httptest"
	"net/url"
	"strings"
	"testing"
	"time"

	"git.dev.pardot.com/Pardot/bread"
)

func TestEventHandler(t *testing.T) {
	const (
		secret          = "shared secret"
		failMagicString = `{"fail": true}`
	)
	endpoint := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, req *http.Request) {
		body, err := ioutil.ReadAll(req.Body)
		if err != nil {
			panic(err)
		}
		if string(body) == failMagicString {
			w.WriteHeader(418)
		} else {
			w.WriteHeader(200)
		}
	}))
	defer endpoint.Close()
	endpointURL, err := url.Parse(endpoint.URL)
	if err != nil {
		t.Fatal(err)
	}
	handler := bread.NewEventHandler(log.New(ioutil.Discard, "", log.LstdFlags), &bread.EventHandlerConfig{
		RequestTimeout:    10 * time.Millisecond,
		GithubEndpoints:   []*url.URL{endpointURL},
		JIRAEndpoints:     []*url.URL{endpointURL},
		GithubSecretToken: secret,
	})
	ts := httptest.NewServer(handler)
	defer ts.Close()
	for _, tc := range []struct {
		status   int
		respBody string
		reqBody  string
		f        func(*http.Request) *http.Request
	}{
		{
			405,
			"unsupported method: GET",
			"{}",
			func(req *http.Request) *http.Request {
				req.URL.Path = "/github"
				req.Method = "GET"
				return req
			},
		},
		{
			400,
			"unsupported content-type: application/xml",
			"{}",
			func(req *http.Request) *http.Request {
				req.URL.Path = "/github"
				req.Header.Set("Content-Type", "application/xml")
				return req
			},
		},
		{
			400,
			"",
			"{}",
			func(req *http.Request) *http.Request {
				req.URL.Path = "/github"
				req.Header.Del("X-Hub-Signature")
				return req
			},
		},
		{
			400,
			"",
			"{}",
			func(req *http.Request) *http.Request {
				req.URL.Path = "/github"
				req.Header.Set("X-Hub-Signature", "badsig")
				return req
			},
		},
		{
			400,
			"signature does not match",
			"{x: true}",
			func(req *http.Request) *http.Request {
				req.URL.Path = "/github"
				req.Header.Set("X-Hub-Signature", "sha1=f7b12f2256197f54286357418bff5d6230f821bf")
				return req
			},
		},
		{
			500,
			`"statusCode":418}]`,
			failMagicString,
			func(req *http.Request) *http.Request {
				req.URL.Path = "/github"
				return req
			},
		},
		{
			404,
			"handler not found: /boomtown",
			"{}",
			func(req *http.Request) *http.Request {
				req.URL.Path = "/boomtown"
				return req
			},
		},
		{
			200,
			"",
			"{}",
			func(req *http.Request) *http.Request {
				req.URL.Path = "/jira"
				return req
			},
		},
		{
			400,
			"invalid character",
			"garbage",
			func(req *http.Request) *http.Request {
				req.URL.Path = "/jira"
				return req
			},
		},
		{
			500,
			"could not proxy to all endpoints",
			failMagicString,
			func(req *http.Request) *http.Request {
				req.URL.Path = "/jira"
				return req
			},
		},
	} {
		hash := hmac.New(sha1.New, []byte(secret))
		if _, err := hash.Write([]byte(tc.reqBody)); err != nil {
			t.Fatal(err)
		}
		req, err := http.NewRequest(http.MethodPost, ts.URL, strings.NewReader(tc.reqBody))
		if err != nil {
			t.Fatal(err)
		}
		req.Header.Add("Content-Type", "application/json")
		req.Header.Add("X-GitHub-Event", "push")
		req.Header.Add("X-Hub-Signature", "sha1="+hex.EncodeToString(hash.Sum(nil)))
		resp, err := http.DefaultClient.Do(tc.f(req))
		if err != nil {
			t.Fatal(err)
		}
		if resp.StatusCode != tc.status {
			t.Errorf("expected status code %d, got %d", tc.status, resp.StatusCode)
		}
		if b, err := ioutil.ReadAll(resp.Body); err != nil {
			t.Error(err)
		} else if !strings.Contains(strings.TrimSpace(string(b)), tc.respBody) {
			t.Errorf("expected response body `%s`, got `%s`", tc.respBody, strings.TrimSpace(string(b)))
		}
	}
}
