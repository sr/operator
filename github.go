package bread

import (
	"bytes"
	"crypto/hmac"
	"crypto/sha1"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"net/url"
	"strings"
	"time"

	"github.com/golang/protobuf/jsonpb"
	"github.com/sr/operator/protolog"

	"git.dev.pardot.com/Pardot/bread/pb"
)

const (
	eventSigHeader    = "X-Hub-Signature"
	eventSigLength    = 45
	eventSigPrefix    = "sha1="
	contentTypeHeader = "Content-Type"
	eventIDHeader     = "X-GitHub-Delivery"
	eventTypeHeader   = "X-GitHub-Event"
	jsonType          = "application/json"
)

type EventHandlerConfig struct {
	RequestTimeout    time.Duration
	RetryDelay        time.Duration
	MaxRetries        int
	GithubSecretToken string
	GithubEndpoints   []*url.URL
	JIRAEndpoints     []*url.URL
}

// NewEventHandler returns an http.Handler that receives JIRA and GitHub events
// webhooks requests and forwards them to other HTTP endpoints after it has
// verified their integrity if possible.
func NewEventHandler(logger protolog.Logger, config *EventHandlerConfig) http.Handler {
	if config.GithubSecretToken == "" {
		panic("required config struct field missing: GithubSecretToken")
	}
	client := &http.Client{CheckRedirect: nil, Jar: nil}
	if config.RequestTimeout != time.Duration(0) {
		client.Timeout = config.RequestTimeout
	}
	return &eventHandler{logger, config, client, &jsonpb.Marshaler{}}
}

type eventHandler struct {
	logger  protolog.Logger
	config  *EventHandlerConfig
	client  *http.Client
	jsonpbm *jsonpb.Marshaler
}

func (h *eventHandler) ServeHTTP(w http.ResponseWriter, req *http.Request) {
	if req.Method != http.MethodPost {
		http.Error(w, fmt.Sprintf("unsupported method: %s", req.Method), http.StatusMethodNotAllowed)
		return
	}
	if !strings.Contains(req.Header.Get(contentTypeHeader), jsonType) {
		http.Error(w, fmt.Sprintf("unsupported content-type: %s", req.Header.Get(contentTypeHeader)), http.StatusBadRequest)
		return
	}
	switch req.URL.Path {
	case "/github":
		h.handleGithub(w, req)
	case "/jira":
		h.handleJIRA(w, req)
	default:
		http.Error(w, fmt.Sprintf("handler not found: %s", req.URL.Path), http.StatusNotFound)
	}
}

func (h *eventHandler) handleJIRA(w http.ResponseWriter, req *http.Request) {
	body, err := ioutil.ReadAll(req.Body)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	type jiraPayload struct {
		ID           int32  `json:"id"`
		WebhookEvent string `json:"webhookEvent"`
		Issue        *struct {
			Key string `json:"key"`
		} `json:"issue"`
	}
	var payload jiraPayload
	if err := json.Unmarshal(body, &payload); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	ev := &breadpb.JIRAEvent{
		Id:   payload.ID,
		Type: payload.WebhookEvent,
	}
	ev.Forwarded = make([]*breadpb.HTTPRequest, len(h.config.JIRAEndpoints))
	if payload.Issue != nil {
		ev.IssueKey = payload.Issue.Key
	}
	defer func() { _ = req.Body.Close() }()
	for i, u := range h.config.JIRAEndpoints {
		retries := 0
		ev.Forwarded[i] = &breadpb.HTTPRequest{Method: http.MethodPost, Path: u.String()}
		for {
			req, err := http.NewRequest(http.MethodPost, u.String(), bytes.NewReader(body))
			if err != nil {
				ev.Forwarded[i].Error = err.Error()
				break
			}
			req.Header.Add(eventTypeHeader, ev.Type)
			req.Header.Add(contentTypeHeader, jsonType)
			resp, err := h.client.Do(req)
			if retries >= h.config.MaxRetries || (resp != nil && (resp.StatusCode >= 200 && resp.StatusCode < 300)) {
				if resp != nil {
					ev.Forwarded[i].StatusCode = uint32(resp.StatusCode)
				}
				if err != nil {
					ev.Forwarded[i].Error = err.Error()
				}
				break
			}
			if h.config.RetryDelay != 0 {
				time.Sleep(h.config.RetryDelay)
			}
			retries++
		}
	}
	h.logger.Info(ev)
	for _, r := range ev.Forwarded {
		if !(r.StatusCode >= 200 && r.StatusCode < 300) {
			http.Error(w, "could not proxy to all endpoints", http.StatusInternalServerError)
			return
		}
	}
	w.WriteHeader(http.StatusOK)
}

func (h *eventHandler) handleGithub(w http.ResponseWriter, req *http.Request) {
	sig := req.Header.Get(eventSigHeader)
	if len(sig) != eventSigLength || !strings.HasPrefix(sig, eventSigPrefix) {
		w.WriteHeader(http.StatusBadRequest)
		return
	}
	body, err := ioutil.ReadAll(req.Body)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer func() { _ = req.Body.Close() }()
	hash := hmac.New(sha1.New, []byte(h.config.GithubSecretToken))
	if _, err = hash.Write(body); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	actual := make([]byte, 20)
	expected := hash.Sum(nil)
	if _, err = hex.Decode(actual, []byte(sig[len(eventSigPrefix):])); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	if !hmac.Equal(actual, expected) {
		http.Error(w, "signature does not match", http.StatusBadRequest)
		return
	}
	ev := &breadpb.GithubEvent{
		Id:        req.Header.Get(eventIDHeader),
		Type:      req.Header.Get(eventTypeHeader),
		Payload:   body,
		Forwarded: make([]*breadpb.HTTPRequest, len(h.config.GithubEndpoints)),
	}
	for i, u := range h.config.GithubEndpoints {
		retries := 0
		ev.Forwarded[i] = &breadpb.HTTPRequest{Method: http.MethodPost, Path: u.String()}
		for {
			req, err := http.NewRequest(http.MethodPost, u.String(), bytes.NewReader(body))
			if err != nil {
				ev.Forwarded[i].Error = err.Error()
				break
			}
			req.Header.Add(eventTypeHeader, ev.Type)
			req.Header.Add(contentTypeHeader, jsonType)
			resp, err := h.client.Do(req)
			if retries >= h.config.MaxRetries || (resp != nil && (resp.StatusCode >= 200 && resp.StatusCode < 300)) {
				if resp != nil {
					ev.Forwarded[i].StatusCode = uint32(resp.StatusCode)
				}
				if err != nil {
					ev.Forwarded[i].Error = err.Error()
				}
				break
			}
			if h.config.RetryDelay != 0 {
				time.Sleep(h.config.RetryDelay)
			}
			retries++
		}
	}
	ev.Payload = nil
	var failure bool
	for _, r := range ev.Forwarded {
		if !(r.StatusCode >= 200 && r.StatusCode < 300) {
			failure = true
		}
	}
	if failure {
		w.WriteHeader(http.StatusInternalServerError)
	} else {
		w.WriteHeader(http.StatusOK)
	}
	if err := h.jsonpbm.Marshal(w, ev); err != nil {
		_, _ = fmt.Fprintf(w, "unable to encode proxy status response: %s", err)
	}
}
