package module

import (
	"io/ioutil"
	"os"
	"testing"

	"github.com/hashicorp/go-getter"
)

// TestTree loads a module at the given path and returns the tree as well
// as a function that should be deferred to clean up resources.
func TestTree(t *testing.T, path string) (*Tree, func()) {
	// Create a temporary directory for module storage
	dir, err := ioutil.TempDir("", "tf")
	if err != nil {
		t.Fatalf("err: %s", err)
		return nil, nil
	}

	// Load the module
	mod, err := NewTreeModule("", path)
	if err != nil {
		t.Fatalf("err: %s", err)
		return nil, nil
	}

	// Get the child modules
	s := &getter.FolderStorage{StorageDir: dir}
	if err := mod.Load(s, GetModeGet); err != nil {
		t.Fatalf("err: %s", err)
		return nil, nil
	}

	return mod, func() {
		os.RemoveAll(dir)
	}
}
