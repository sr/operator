package bread

import (
	"net/http"
	"net/url"

	"github.com/sr/operator"
)

const defaultPlan = "BREAD-BREAD"

type bambooAPIServer struct {
	operator.Replier
	bamboo    *http.Client
	bambooURL *url.URL
}

type bambooTransport struct {
	Username string
	Password string
}

func (t bambooTransport) RoundTrip(req *http.Request) (*http.Response, error) {
	req.SetBasicAuth(t.Username, t.Password)
	req.Header.Set("Accept", "application/json")
	return http.DefaultTransport.RoundTrip(req)
}

func (t *bambooTransport) Client() *http.Client {
	return &http.Client{Transport: t}
}
