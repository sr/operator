package bread

import (
	"crypto/hmac"
	"crypto/sha1"
	"encoding/hex"
	"io/ioutil"
	"net/http"
	"strings"

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

// NewGithubHandler returns an http.Handler that receives Github organization
// event webhook requests. For now all it does is verify the signature of the
// request to validate it originated from Github and wasn't tempered with then
// log to parsed payload to standard output.
//
// The secret argument is required and this will panic if it is not set.
func NewGithubHandler(logger protolog.Logger, secret string) http.Handler {
	if secret == "" {
		panic("required argument missing: secret")
	}
	return &githubHandler{logger, secret}
}

type githubHandler struct {
	logger protolog.Logger
	secret string
}

func (h *githubHandler) ServeHTTP(w http.ResponseWriter, req *http.Request) {
	if req.Method != http.MethodPost {
		w.WriteHeader(http.StatusMethodNotAllowed)
		return
	}
	if !strings.Contains(req.Header.Get(contentTypeHeader), jsonType) {
		w.WriteHeader(http.StatusBadRequest)
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
	hash := hmac.New(sha1.New, []byte(h.secret))
	if _, err = hash.Write(body); err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
	actual := make([]byte, 20)
	expected := hash.Sum(nil)
	if _, err = hex.Decode(actual, []byte(sig[len(eventSigPrefix):])); err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
	if !hmac.Equal(actual, expected) {
		http.Error(w, "signature does not match", http.StatusBadRequest)
		return
	}
	ev := &breadpb.GithubEvent{
		Id:      req.Header.Get(eventIDHeader),
		Type:    req.Header.Get(eventTypeHeader),
		Payload: body,
	}
	h.logger.Info(ev)
	w.WriteHeader(http.StatusOK)
}
