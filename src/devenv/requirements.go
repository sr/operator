package devenv

import (
	"devenv/docker"
	"os"
	"path"
)

// UnsatisfiedRequirements returns a list of any issues that might prevent
// devenv from running properly. If no issues are present, an empty slice will be
// returned.
func UnsatisfiedRequirements() []string {
	errors := []string{}
	if !docker.IsInstalled() {
		errors = append(errors, "The Docker client is not installed. Please download and install: https://download.docker.com/mac/stable/Docker.dmg")
	}

	home := os.Getenv("HOME")
	if _, err := os.Stat(path.Join(home, ".ssh", "id_rsa.pub")); err != nil {
		errors = append(errors, "~/.ssh/id_rsa.pub is not available. Please generate an RSA key with a passphrase: ssh-keygen -t rsa -f ~/.ssh/id_rsa.pub")
	}

	return errors
}
