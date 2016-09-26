package bread

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"

	"github.com/sr/operator"

	"golang.org/x/net/context"

	"bread/pb"
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

func (s *bambooAPIServer) ListBuilds(ctx context.Context, req *breadpb.ListBuildsRequest) (*operator.Response, error) {
	var plan string
	if req.Plan == "" {
		plan = defaultPlan
	} else {
		plan = req.Plan
	}
	resp, err := s.bamboo.Get(fmt.Sprintf("%s/rest/api/latest/result/%s?includeAllStates=true", s.bambooURL, plan))
	if err != nil {
		return nil, err
	}
	defer func() { _ = resp.Body.Close() }()
	if resp.StatusCode != 200 {
		return nil, fmt.Errorf("Bamboo API request failed with status %d", resp.StatusCode)
	}
	var data struct {
		Results struct {
			Result []struct {
				State          string `json:"buildState"`
				LifeCycleState string `json:"lifeCycleState"`
				Key            string `json:"key"`
			} `json:"result"`
		} `json:"results"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&data); err != nil {
		return nil, err
	}
	var out bytes.Buffer
	for _, build := range data.Results.Result {
		var state string
		if build.LifeCycleState == "Finished" {
			state = build.State
		} else {
			state = "Building..."
		}
		fmt.Fprintf(
			&out,
			"%s %s %s\n",
			build.Key,
			state,
			fmt.Sprintf("%s/%s", s.bambooURL, build.Key),
		)
	}
	return operator.Reply(s, ctx, req, &operator.Message{Text: out.String()})
}
