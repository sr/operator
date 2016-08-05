package devenv

import (
	"fmt"
	"os"
	"path"
)

const (
	Version = "0.0.0"
)

// EnsurePersistentDirectoryCreated ensures a directory underneath ~/.devenv is
// created and ready for use. If clear is true, the directory is recursively
// removed and recreated.
func EnsurePersistentDirectoryCreated(name string, clear bool) (string, error) {
	home := os.Getenv("HOME")
	if len(home) <= 0 {
		return "", fmt.Errorf("unable to retrieve the value of $HOME")
	}

	pathname := path.Join(home, ".devenv", name)

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
