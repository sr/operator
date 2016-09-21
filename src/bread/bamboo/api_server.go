package breadbamboo

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"text/tabwriter"

	"golang.org/x/net/context"
)

const defaultPlan = "BREAD-BREAD"

type apiServer struct {
	bamboo    *http.Client
	bambooURL *url.URL
}

func newAPIServer(bamboo *http.Client, bambooURL *url.URL) (*apiServer, error) {
	return &apiServer{bamboo, bambooURL}, nil
}

func (s *apiServer) ListBuilds(ctx context.Context, in *ListBuildsRequest) (*ListBuildsResponse, error) {
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
	return &ListBuildsResponse{
		Message: out.String(),
	}, nil
}
