package devenv

import (
	"io"
	"log"
	"log/syslog"
	"os"
	"path"

	"github.com/fsouza/go-dockerclient"
)

const (
	Version = "0.0.0"

	preferencesSubdirectory = ".devenv"
)

var (
	// DaemonLogger is a logger appropriate for use for background tasks. It
	// outputs to syslog if possible.
	DaemonLogger *log.Logger
)

func init() {
	var w io.Writer

	w, err := syslog.New(syslog.LOG_NOTICE|syslog.LOG_DAEMON, "devenv")
	if err != nil {
		DaemonLogger = log.New(os.Stderr, "devenv", log.LstdFlags)
		DaemonLogger.Printf("unable to log to syslog, falling back to stderr: %v\n", err)
	} else {
		DaemonLogger = log.New(w, "", 0)
	}
}

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

func NewSSHForwarder(client *docker.Client) *SSHForwarder {
	return &SSHForwarder{
		client: client,
	}
}
