package devenv_test

import (
	"devenv"
	"io/ioutil"
	"os"
	"path"
	"testing"
)

// Creates a docker-compose.yml file in a directory hierarchy, and makes sure
// our function can find it by searching up the directory tree.
func TestFindsComposeFile(t *testing.T) {
	tempDir, err := ioutil.TempDir("", "devenv")
	if err != nil {
		t.Error(err)
	}
	defer func() { _ = os.RemoveAll(tempDir) }()

	err = os.MkdirAll(path.Join(tempDir, "dir1", "dir2", "dir3"), 0700)
	if err != nil {
		t.Fatal(err)
	}

	dockerComposeFile := path.Join(tempDir, "dir1", "docker-compose.yml")
	err = ioutil.WriteFile(dockerComposeFile, []byte{}, 0700)
	if err != nil {
		t.Fatal(err)
	}

	file := devenv.FindDockerComposeFile("docker-compose.yml", path.Join(tempDir, "dir1", "dir2", "dir3"))
	if file != dockerComposeFile {
		t.Fatalf("expected %v, got %v", dockerComposeFile, file)
	}

	file = devenv.FindDockerComposeFile("nananana-batman.yml", path.Join(tempDir, "dir1", "dir2", "dir3"))
	if file != "" {
		t.Fatalf("expected %v, got %v", "", file)
	}
}
