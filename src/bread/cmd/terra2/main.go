package main

import (
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"io/ioutil"
	"net/http"
	"net/url"
	"os"
	"os/exec"
	"strings"
)

type localState struct {
	userEmail    string
	estate       string
	planFile     string
	gitBranch    string
	gitSHA1      string
	terraVersion string
	canoeURL     string
}

func main() {
	state := &localState{}
	flag.StringVar(&state.userEmail, "user", "", "")
	flag.StringVar(&state.estate, "estate", "", "")
	flag.StringVar(&state.gitBranch, "branch", "", "")
	flag.StringVar(&state.gitSHA1, "commit", "", "")
	flag.StringVar(&state.terraVersion, "terraform-version", "", "")
	flag.StringVar(&state.planFile, "plan", "", "")
	flag.StringVar(&state.canoeURL, "canoe-url", "https://canoe.dev.pardot.com", "")
	flag.Parse()
	if err := apply(state); err != nil {
		fmt.Fprintf(os.Stderr, "terr2: %v\n", err)
		os.Exit(1)
	}
}

func apply(state *localState) error {
	if _, err := os.Stat(state.planFile); os.IsNotExist(err) {
		return fmt.Errorf(`Plan file "%s" is missing. Please run "terra plan %s" first`, state.planFile, state.estate)
	}
	payload := url.Values{}
	payload.Set("user_email", state.userEmail)
	payload.Set("estate", state.estate)
	payload.Set("branch", state.gitBranch)
	payload.Set("commit", state.gitSHA1)
	payload.Set("terraform_version", state.terraVersion)
	resp, err := doCanoeAPI(
		"POST",
		state.canoeURL+"/api/terraform/deploys",
		payload.Encode(),
	)
	if err != nil {
		return fmt.Errorf("canoe request failed: %v", err)
	}
	defer func() { _ = resp.Body.Close() }()
	var data struct {
		Error    bool   `json:"error"`
		Message  string `json:"message"`
		DeployID int    `json:"deploy_id"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&data); err != nil {
		return err
	}
	if data.Error {
		return errors.New(data.Message)
	}
	if data.DeployID == 0 {
		return errors.New("canoe API response did not include a URL for completing the deploy")
	}
	cmd := exec.Command("terraform", "apply", state.planFile)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	terraErr := cmd.Run()
	if terraErr != nil {
		_ = os.Remove(state.planFile)
	}
	payload.Set("deploy_id", fmt.Sprintf("%d", data.DeployID))
	if terraErr == nil {
		payload.Set("successful", "true")
	} else {
		payload.Set("successful", "false")
	}
	if _, err = doCanoeAPI("POST", state.canoeURL+"/api/terraform/complete_deploy", payload.Encode()); err != nil {
		fmt.Fprintf(os.Stderr, "terra2: could not unlock Terraform deploys\n")
	}
	return terraErr
}

func doCanoeAPI(meth, url, body string) (*http.Response, error) {
	req, err := http.NewRequest(meth, url, strings.NewReader(body))
	if err != nil {
		return nil, err
	}
	req.Header.Set("X-Api-Token", os.Getenv("CANOE_API_TOKEN"))
	if body != "" {
		req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	}
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return nil, err
	}
	if resp.StatusCode != http.StatusOK {
		if body, err := ioutil.ReadAll(resp.Body); err == nil {
			return nil, fmt.Errorf("canoe API request failed with status %d and body: %s", resp.StatusCode, body)
		}
		return nil, fmt.Errorf("canoe API request failed with status %d", resp.StatusCode)
	}
	return resp, nil
}
