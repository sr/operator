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
	"os/signal"
	"path/filepath"
	"strings"
	"syscall"
)

const program = "terra2"

type afyRepo struct {
	RepoName string
	URL      string
	User     string
	Password string
}

type gitRepo struct {
	SHA1   string
	Branch string
}

type terraform struct {
	// Exec is the path to the terraform executable.
	Exec string
	// Cmd is the terraform subcommand to run
	Cmd string
	// Basedir is the directory within the repository where all terraform
	// files are located
	Basedir string
	// Basedir is the directory relative to Basedir under which the *.tf files
	// describing a particular infrastructure estate (such as an AWS account) are
	// located
	Dir string
	// PlanFile is the terraform plan file to create or apply
	PlanFile string
	// VarFile is the is the *.tfvars given to terraform as the -var-file flag
	VarFile string
	// Version is the version of the terraform the executable
	Version []byte
}

func main() {
	status, out := terra()
	if out != "" {
		fmt.Fprintf(os.Stderr, fmt.Sprintf("%s: %s\n", program, out))
	}
	os.Exit(status)
}

func terra() (int, string) {
	var (
		afy       afyRepo
		canoeURL  string
		canoeUser string
		git       gitRepo
		tf        terraform
	)
	flag.StringVar(&afy.URL, "artifactory-url", "https://artifactory.dev.pardot.com/artifactory", "Full URL of the Artifactory server")
	flag.StringVar(&afy.RepoName, "artifactory-repo", "pd-terraform", "Name of the Artifactory repository where Terraform configs, remote state, and plans are stored")
	flag.StringVar(&afy.User, "artifactory-user", "", "User used for accessing the Artifactory API")
	flag.StringVar(&afy.Password, "artifactory-password", "", "Encrypted password of the Artifactory API user")
	flag.StringVar(&canoeUser, "canoe-user", "", "The email address used for authenticating Canoe API requests")
	flag.StringVar(&canoeURL, "canoe-url", "https://canoe.dev.pardot.com", "")
	flag.StringVar(&git.Branch, "git-branch", "", "The current git branch")
	flag.StringVar(&git.SHA1, "git-commit", "", "The SHA1 of the current commit (HEAD)")
	flag.StringVar(&tf.Cmd, "terraform-command", "plan", "Terraform action to execute. Must be one of \"plan\" or \"apply\"")
	flag.StringVar(&tf.Basedir, "terraform-basedir", "", "Terraform base directory")
	flag.StringVar(&tf.Dir, "terraform-dir", "aws/pardotops", "Terraform directory, relative to the base directory")
	flag.StringVar(&tf.Exec, "terraform-exec", "terraform", "Path to the terraform executable")
	flag.StringVar(&tf.PlanFile, "terraform-plan", "", "")
	flag.StringVar(&tf.VarFile, "terraform-var-file", "", "")
	flag.Parse()
	if afy.URL == "" {
		return 1, "required flag missing: artifactory-url"
	}
	if afy.RepoName == "" {
		return 1, "required flag missing: artifactory-repo"
	}
	if afy.User == "" {
		return 1, "required flag missing: artifactory-user"
	}
	if afy.Password == "" {
		return 1, "required flag missing: artifactory-password"
	}
	if canoeURL == "" {
		return 1, "required flag missing: canoe-url"
	}
	if canoeUser == "" {
		return 1, "required flag missing: canoe-user"
	}
	if git.Branch == "" {
		return 1, "required flag missing: git-branch"
	}
	if git.SHA1 == "" {
		return 1, "required flag missing: git-commit"
	}
	if tf.Cmd == "" {
		return 1, "required flag missing: terraform-command"
	}
	if tf.Exec == "" {
		return 1, "required flag missing: terraform-exec"
	}
	if tf.PlanFile == "" {
		return 1, "required flag missing: terraform-plan"
	}
	cmd := exec.Command(
		tf.Exec,
		"remote",
		"config",
		"-backend=artifactory",
		fmt.Sprintf("-backend-config=url=%s", afy.URL),
		fmt.Sprintf(`-backend-config=repo=%s`, afy.RepoName),
		fmt.Sprintf(`-backend-config=subpath=%s`, tf.Dir),
	)
	cmd.Env = []string{
		fmt.Sprintf("ARTIFACTORY_USERNAME=%s", afy.User),
		fmt.Sprintf("ARTIFACTORY_PASSWORD=%s", afy.Password),
	}
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	c := make(chan os.Signal, 1)
	signal.Notify(c, os.Interrupt)
	go func() {
		for sig := range c {
			if cmd.Process != nil {
				_ = cmd.Process.Signal(sig)
			}
		}
	}()
	if err := cmd.Run(); err != nil {
		return 1, ""
	}
	var err error
	switch tf.Cmd {
	case "plan":
		if tf.Basedir == "" {
			return 1, "required flag missing: terraform-basedir"
		}
		if tf.Dir == "" {
			return 1, "required flag missing: terraform-dir"
		}
		if tf.VarFile == "" {
			return 1, "required flag missing: terraform-var-file"
		}
		if _, err := os.Stat(tf.Basedir); os.IsNotExist(err) {
			return 1, fmt.Sprintf("Terraform base directory \"%s\" does not exist.", tf.Basedir)
		}
		if _, err := os.Stat(filepath.Join(tf.Basedir, tf.Dir)); os.IsNotExist(err) {
			return 1, fmt.Sprintf("Terraform directory \"%s\" not present in base directory.", tf.Basedir)
		}
		var relPath string
		if relPath, err = filepath.Rel(tf.Basedir, tf.VarFile); err != nil {
			relPath = tf.VarFile
		}
		if _, err := os.Stat(tf.VarFile); os.IsNotExist(err) {
			return 1, fmt.Sprintf("Required Terraform var file \"%s\" is missing. Please see \"%s.sample\" for an example.", relPath, relPath)
		}
		return plan(&tf)
	case "apply":
		cmd := exec.Command(tf.Exec, "version")
		if tf.Version, err = cmd.CombinedOutput(); err != nil {
			return 1, "Unable to determine local Terraform version"
		}
		if _, err := os.Stat(tf.PlanFile); os.IsNotExist(err) {
			return 1, fmt.Sprintf(`Plan file "%s" is missing. Please run "terra plan %s" first`, tf.PlanFile, tf.PlanFile)
		}
		if err := apply(&tf, &git, canoeURL, canoeUser); err != nil {
			return 1, err.Error()
		}
		return 0, ""
	default:
		return 1, fmt.Sprintf("Invalid action: \"%s\". Must be one of \"plan\" or \"apply\"", tf.Cmd)
	}
}

func plan(tf *terraform) (int, string) {
	cmd := exec.Command(
		tf.Exec,
		"plan",
		"-detailed-exitcode",
		"-input=false",
		"-var-file="+tf.VarFile,
		"-out="+tf.PlanFile,
		filepath.Join(tf.Basedir, tf.Dir),
	)
	cmd.Dir = filepath.Join(tf.Basedir, tf.Dir)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	c := make(chan os.Signal, 1)
	signal.Notify(c, os.Interrupt)
	go func() {
		for sig := range c {
			if cmd.Process != nil && cmd.ProcessState != nil && !cmd.ProcessState.Exited() {
				_ = cmd.Process.Signal(sig)
			}
		}
	}()
	if err := cmd.Run(); err != nil {
		if exiterr, ok := err.(*exec.ExitError); ok {
			if status, ok := exiterr.Sys().(syscall.WaitStatus); ok {
				return status.ExitStatus(), ""
			}
		} else {
			return 3, err.Error()
		}
	}
	return 0, ""
}

func apply(tf *terraform, git *gitRepo, canoeURL string, canoeUser string) error {
	payload := url.Values{}
	payload.Set("user_email", canoeURL)
	payload.Set("estate", tf.Dir)
	payload.Set("branch", git.Branch)
	payload.Set("commit", git.SHA1)
	payload.Set("terraform_version", string(tf.Version))
	resp, err := doCanoeAPI(
		"POST",
		canoeURL+"/api/terraform/deploys",
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
	cmd := exec.Command(tf.Exec, "apply", tf.PlanFile)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	c := make(chan os.Signal, 1)
	signal.Notify(c, os.Interrupt)
	go func() {
		for sig := range c {
			if cmd.Process != nil {
				_ = cmd.Process.Signal(sig)
			}
		}
	}()
	terraErr := cmd.Run()
	if terraErr != nil {
		_ = os.Remove(tf.PlanFile)
	}
	payload.Set("deploy_id", fmt.Sprintf("%d", data.DeployID))
	if terraErr == nil {
		payload.Set("successful", "true")
	} else {
		payload.Set("successful", "false")
	}
	if _, err = doCanoeAPI("POST", canoeURL+"/api/terraform/complete_deploy", payload.Encode()); err != nil {
		fmt.Fprintf(os.Stderr, "%s: Could not unlock Terraform estate %s\n", program, "TODO")
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
			return nil, fmt.Errorf("Canoe API request failed with status %d and body: %s", resp.StatusCode, body)
		}
		return nil, fmt.Errorf("Canoe API request failed with status %d", resp.StatusCode)
	}
	return resp, nil
}
