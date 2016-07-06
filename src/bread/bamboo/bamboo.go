package breadbamboo

import (
	"net/http"
	"net/url"
)

type BambooTransport struct {
	Username string
	Password string
}

func NewAPIServer(config *BambooConfig) (BambooServer, error) {
	bamboo := &BambooTransport{
		Username: config.BambooUsername,
		Password: config.BambooPassword,
	}
	u, err := url.Parse(config.BambooUrl)
	if err != nil {
		return nil, err
	}
	return newAPIServer(bamboo.Client(), u)
}

func (t BambooTransport) RoundTrip(req *http.Request) (*http.Response, error) {
	req.SetBasicAuth(t.Username, t.Password)
	req.Header.Set("Accept", "application/json")
	return http.DefaultTransport.RoundTrip(req)
}

func (t *BambooTransport) Client() *http.Client {
	return &http.Client{Transport: t}
}
