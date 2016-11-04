package main

import (
	"bread"
	"bread/swagger/client/canoe"
	"bread/swagger/models"
	"errors"
	"flag"
	"fmt"
	"net/url"
	"os"
	"os/exec"
	"os/signal"
	"path/filepath"
	"regexp"
	"strings"
	"syscall"
)

const program = "terra2"

var reTerraVersion = regexp.MustCompile("v([0-9.]*)")

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
	// Dir is the directory within the repository where configuration for all
	// terraform projects is
	Dir string
	// Project is the name of a Terraform project, such as aws/pardotops
	Project string
	// PlanFile is the terraform plan file to create or apply
	PlanFile string
	// VarFile is the is the *.tfvars given to terraform as the -var-file flag
	VarFile string
	// Version is the version of the terraform the executable
	Version string
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
	flag.StringVar(&afy.RepoName, "artifactory-repo", "pd-terraform", "Name of the Artifactory repository where Terraform configs, remote project, and plans are stored")
	flag.StringVar(&afy.User, "artifactory-user", "", "User used for accessing the Artifactory API")
	flag.StringVar(&afy.Password, "artifactory-password", "", "Encrypted password of the Artifactory API user")
	flag.StringVar(&canoeUser, "canoe-user", "", "The email address used for authenticating Canoe API requests")
	flag.StringVar(&canoeURL, "canoe-url", "https://canoe.dev.pardot.com", "")
	flag.StringVar(&git.Branch, "git-branch", "", "The current git branch")
	flag.StringVar(&git.SHA1, "git-commit", "", "The SHA1 of the current commit (HEAD)")
	flag.StringVar(&tf.Cmd, "terraform-command", "plan", "Terraform action to execute. Must be one of \"plan\" or \"apply\"")
	flag.StringVar(&tf.Dir, "terraform-dir", "", "Terraform base directory")
	flag.StringVar(&tf.Project, "terraform-project", "aws/pardotops", "Terraform project")
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
	if tf.Cmd == "" {
		return 1, "required flag missing: terraform-command"
	}
	if tf.Exec == "" {
		return 1, "required flag missing: terraform-exec"
	}
	u, err := url.Parse(canoeURL)
	if err != nil {
		return 1, "flag canoe-url is not a valid URL: " + err.Error()
	}
	client := bread.NewCanoeClient(u, "")
	cmd := exec.Command(
		tf.Exec,
		"remote",
		"config",
		"-backend=artifactory",
		fmt.Sprintf("-backend-config=url=%s", afy.URL),
		fmt.Sprintf(`-backend-config=repo=%s`, afy.RepoName),
		fmt.Sprintf(`-backend-config=subpath=%s`, tf.Project),
		fmt.Sprintf(`-backend-config=username=%s`, afy.User),
		fmt.Sprintf(`-backend-config=password=%s`, afy.Password),
	)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Dir = filepath.Join(tf.Dir, tf.Project)
	if err := cmd.Run(); err != nil {
		return 1, err.Error()
	}
	switch tf.Cmd {
	case "plan":
		if tf.Dir == "" {
			return 1, "required flag missing: terraform-dir"
		}
		if tf.Project == "" {
			return 1, "required flag missing: terraform-project"
		}
		if tf.VarFile == "" {
			return 1, "required flag missing: terraform-var-file"
		}
		if tf.PlanFile == "" {
			return 1, "required flag missing: terraform-plan"
		}
		if _, err := os.Stat(tf.Dir); os.IsNotExist(err) {
			return 1, fmt.Sprintf("Terraform directory \"%s\" does not exist.", tf.Dir)
		}
		if _, err := os.Stat(filepath.Join(tf.Dir, tf.Project)); os.IsNotExist(err) {
			return 1, fmt.Sprintf("Terraform project \"%s\" not present in base directory.", tf.Project)
		}
		relPath, err := filepath.Rel(tf.Dir, tf.VarFile)
		if err != nil {
			relPath = tf.VarFile
		}
		if _, err := os.Stat(tf.VarFile); os.IsNotExist(err) {
			return 1, fmt.Sprintf("Required Terraform var file \"%s\" is missing. Please see \"%s.sample\" for an example.", relPath, relPath)
		}
		return plan(&tf)
	case "apply":
		if tf.PlanFile == "" {
			return 1, "required flag missing: terraform-plan"
		}
		if git.Branch == "" {
			return 1, "required flag missing: git-branch"
		}
		if git.SHA1 == "" {
			return 1, "required flag missing: git-commit"
		}
		cmd := exec.Command(tf.Exec, "version")
		v, err := cmd.CombinedOutput()
		matches := reTerraVersion.FindStringSubmatch(string(v))
		if err != nil && len(matches) != 2 {
			return 1, "Unable to determine local Terraform version"
		}
		tf.Version = matches[1]
		if _, err := os.Stat(tf.PlanFile); os.IsNotExist(err) {
			return 1, fmt.Sprintf(`Plan file "%s" is missing. Please run "terra plan %s" first`, tf.PlanFile, tf.PlanFile)
		}
		if err := apply(client, &tf, &git, canoeUser); err != nil {
			return 1, err.Error()
		}
		return 0, ""
	case "unlock":
		if tf.Project == "" {
			return 1, "required flag missing: terraform-project"
		}
		if _, err := client.UnlockTerraformProject(
			canoe.NewUnlockTerraformProjectParams().
				WithTimeout(bread.CanoeTimeout).
				WithBody(&models.CanoeUnlockTerraformProjectRequest{
					UserEmail: canoeUser,
					Project:   tf.Project,
				}),
		); err != nil {
			return 1, fmt.Sprintf("Could not unlock Terraform project: %s\n", err)
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
		filepath.Join(tf.Dir, tf.Project),
	)
	cmd.Dir = filepath.Join(tf.Dir, tf.Project)
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

func apply(client bread.CanoeClient, tf *terraform, git *gitRepo, canoeUser string) error {
	resp, err := client.CreateTerraformDeploy(
		canoe.NewCreateTerraformDeployParams().
			WithTimeout(bread.CanoeTimeout).
			WithBody(&models.CanoeCreateTerraformDeployRequest{
				UserEmail:        canoeUser,
				Project:          tf.Project,
				Branch:           git.Branch,
				Commit:           git.SHA1,
				TerraformVersion: strings.TrimSpace(tf.Version),
			}),
	)
	if err != nil {
		return fmt.Errorf("canoe request failed: %v", err)
	}
	if resp.Payload.Error {
		return errors.New(resp.Payload.Message)
	}
	if resp.Payload.DeployID == 0 {
		return errors.New("canoe API response did not include a URL for completing the deploy")
	}
	cmd := exec.Command(tf.Exec, "apply", tf.PlanFile)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Dir = filepath.Join(tf.Dir, tf.Project)
	c := make(chan os.Signal, 1)
	signal.Notify(c, os.Interrupt)
	go func() {
		for sig := range c {
			if cmd.Process != nil {
				_ = cmd.Process.Signal(sig)
			}
		}
	}()
	var success bool
	terraErr := cmd.Run()
	if terraErr != nil {
		_ = os.Remove(tf.PlanFile)
	} else {
		success = true
	}
	if _, err := client.CompleteTerraformDeploy(
		canoe.NewCompleteTerraformDeployParams().
			WithTimeout(bread.CanoeTimeout).
			WithBody(&models.CanoeCompleteTerraformDeployRequest{
				UserEmail:  canoeUser,
				DeployID:   resp.Payload.DeployID,
				Successful: success,
				RequestID:  resp.Payload.RequestID,
				Project:    resp.Payload.Project,
			}),
	); err != nil {
		fmt.Fprintf(os.Stderr, "%s: Could not unlock Terraform project: %s\n", program, err)
	}
	return terraErr
}
