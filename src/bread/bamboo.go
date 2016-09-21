package bread

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"text/tabwriter"

	"golang.org/x/net/context"

	"bread/pb"
)

const defaultPlan = "BREAD-BREAD"

type bambooAPIServer struct {
	bamboo    *http.Client
	bambooURL *url.URL
}

type bambooTransport struct {
	Username string
	Password string
}

func newBambooAPIServer(config *BambooConfig) (*bambooAPIServer, error) {
	bamboo := &bambooTransport{
		Username: config.Username,
		Password: config.Password,
	}
	u, err := url.Parse(config.URL)
	if err != nil {
		return nil, err
	}
	return &bambooAPIServer{bamboo.Client(), u}, nil
}

func (t bambooTransport) RoundTrip(req *http.Request) (*http.Response, error) {
	req.SetBasicAuth(t.Username, t.Password)
	req.Header.Set("Accept", "application/json")
	return http.DefaultTransport.RoundTrip(req)
}

func (t *bambooTransport) Client() *http.Client {
	return &http.Client{Transport: t}
}

func (s *bambooAPIServer) ListBuilds(ctx context.Context, in *breadpb.ListBuildsRequest) (*breadpb.ListBuildsResponse, error) {
	var plan string
	if in.Plan == "" {
		plan = defaultPlan
	} else {
		plan = in.Plan
	}
	resp, err := s.bamboo.Get(fmt.Sprintf("%s/rest/api/latest/result/%s", s.bambooURL, plan))
	if err != nil {
		return nil, err
	}
	defer func() { _ = resp.Body.Close() }()
	if resp.StatusCode != 200 {
		return nil, fmt.Errorf("bamboo request failed with status %d", resp.StatusCode)
	}
	var data struct {
		Results struct {
			Result []struct {
				LifeCycleState string `json:"lifeCycleState"`
				Key            string `json:"key"`
			} `json:"result"`
		} `json:"results"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&data); err != nil {
		return nil, err
	}
	var (
		out bytes.Buffer
		w   tabwriter.Writer
	)
	w.Init(&out, 0, 4, 1, '\t', 0)
	fmt.Fprintf(&w, "%s\t%s\t%s\n", "ID", "STATUS", "URL")
	for _, build := range data.Results.Result {
		fmt.Fprintf(
			&w,
			"%s\t%s\t%s\n",
			build.Key,
			build.LifeCycleState,
			fmt.Sprintf("%s/%s", s.bambooURL, build.Key),
		)
	}
	if err := w.Flush(); err != nil {
		return nil, err
	}
	return &breadpb.ListBuildsResponse{
		Message: out.String(),
	}, nil
}
