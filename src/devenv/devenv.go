package devenv

import (
	"os"
	"path"
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
