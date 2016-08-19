package devenv

import (
	"log"
	"os"
	"path"

	"github.com/fsouza/go-dockerclient"
)

const (
	Version = "0.0.0"

	preferencesSubdirectory = ".devenv"
)

// EnsurePersistentDirectoryCreated ensures a directory underneath ~/.devenv is
// created and ready for use. If clear is true, the directory is recursively
// removed and recreated.
func EnsurePersistentDirectoryCreated(name string, clear bool) (string, error) {
	pathname := path.Join(os.Getenv("HOME"), preferencesSubdirectory, name)

	if clear {
		if err := os.RemoveAll(pathname); err != nil {
			return "", err
		}
	}

	if err := os.MkdirAll(pathname, 0700); err != nil {
		return "", err
	}

	return pathname, nil
}

// UnsatisfiedRequirements returns a list of any issues that might prevent
// devenv from running properly. If no issues are present, an empty slice will be
// returned.
func UnsatisfiedRequirements() []string {
	errors := []string{}
	if _, err := os.Stat(path.Join(os.Getenv("HOME"), ".ssh", "id_rsa.pub")); err != nil {
		errors = append(errors, "~/.ssh/id_rsa.pub is not available. Please generate an RSA key with a passphrase: ssh-keygen -t rsa -f ~/.ssh/id_rsa.pub")
	}

	return errors
}

func NewSSHForwarder(client *docker.Client, logger *log.Logger) *SSHForwarder {
	return &SSHForwarder{
		client: client,
		logger: logger,
	}
}
