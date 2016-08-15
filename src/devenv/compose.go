package devenv

import (
	"os"
	"path"
	"path/filepath"
)

// FindDockerComposeFile finds a docker-compose.yml file in the given directory
// hierarchy. Returns the full path of the found docker-compose.yml file and an
// error. If the function cannot find a docker-compose.yml, an empty string is
// returned.
func FindDockerComposeFile(baseName string, dir string) string {
	for dir != "/" {
		file := path.Join(dir, baseName)
		if _, err := os.Stat(file); err == nil {
			return file
		}

		dir = filepath.Clean(path.Join(dir, ".."))
	}

	return ""
}
