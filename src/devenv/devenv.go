package devenv

import (
	"fmt"
	"io"
	"log"
	"os"
	"path"
	"syscall"

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
		if err := removeAllChildren(pathname); err != nil {
			return "", err
		}
	}

	if err := os.MkdirAll(pathname, 0700); err != nil {
		return "", err
	}

	return pathname, nil
}

func removeAllChildren(pathname string) error {
	dir, err := os.Lstat(pathname)
	if err != nil {
		if err, ok := err.(*os.PathError); ok && (os.IsNotExist(err.Err) || err.Err == syscall.ENOTDIR) {
			return nil
		}
		return err
	}

	if !dir.IsDir() {
		return fmt.Errorf("%v: not a directory", dir)
	}

	fd, err := os.Open(pathname)
	if err != nil {
		if os.IsNotExist(err) {
			return nil
		}
		return err
	}
	defer func() { _ = fd.Close() }()

	for {
		names, err := fd.Readdirnames(100)
		if err == io.EOF {
			return nil
		} else if err != nil {
			return err
		}

		for _, name := range names {
			if err := os.RemoveAll(path.Join(pathname, name)); err != nil {
				return err
			}
		}
	}
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
