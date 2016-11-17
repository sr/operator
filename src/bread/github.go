package bread

import (
	"bytes"
	"crypto/hmac"
	"crypto/sha1"
	"encoding/hex"
	"fmt"
	"io/ioutil"
	"net/http"
	"net/url"
	"strings"
	"time"

	"github.com/sr/operator/protolog"

	"bread/pb"
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

type GithubHandlerConfig struct {
	RequestTimeout time.Duration
	RetryDelay     time.Duration
	MaxRetries     int
	SecretToken    string
	Endpoints      []*url.URL
}

// NewGithubHandler returns an http.Handler that receives Github organization
// event webhook requests and forwards them to other HTTP endpoints after it
// has verified the integrity of the request.
func NewGithubHandler(logger protolog.Logger, config *GithubHandlerConfig) http.Handler {
	if config.SecretToken == "" {
		panic("required setting missing: SecretToken")
	}
	client := &http.Client{CheckRedirect: nil, Jar: nil}
	if config.RequestTimeout != time.Duration(0) {
		client.Timeout = config.RequestTimeout
	}
	return &githubHandler{logger, config, client}
}

type githubHandler struct {
	logger protolog.Logger
	config *GithubHandlerConfig
	client *http.Client
}

func (h *githubHandler) ServeHTTP(w http.ResponseWriter, req *http.Request) {
	if req.Method != http.MethodPost {
		http.Error(w, fmt.Sprintf("unsupported method: %s", req.Method), http.StatusMethodNotAllowed)
		return
	}
	if !strings.Contains(req.Header.Get(contentTypeHeader), jsonType) {
		http.Error(w, fmt.Sprintf("unsupported content-type: %s", req.Header.Get(contentTypeHeader)), http.StatusBadRequest)
		return
	}
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
	hash := hmac.New(sha1.New, []byte(h.config.SecretToken))
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
		Forwarded: make([]*breadpb.HTTPRequest, len(h.config.Endpoints)),
	}
	for i, u := range h.config.Endpoints {
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
	h.logger.Info(ev)
	for _, r := range ev.Forwarded {
		if !(r.StatusCode >= 200 && r.StatusCode < 300) {
			http.Error(w, "could not proxy to all endpoints", http.StatusInternalServerError)
			return
		}
	}
	w.WriteHeader(http.StatusOK)
}
