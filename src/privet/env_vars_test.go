package privet

import (
	"os"
	"testing"
)

func TestRetrieveEnvVars(t *testing.T) {
	os.Setenv("FOO", "bar")
	result := retrieveEnvVars([]string{"FOO", "NOTHINGTOSEEHERE"})

	if len(result) != 2 {
		t.Fatalf("expected result to have two elements, but got %v", result)
	}
	if result[0] != "FOO=bar" {
		t.Fatalf("expected FOO=bar but got %v", result[0])
	}
	if result[1] != "NOTHINGTOSEEHERE=" {
		t.Fatalf("expected NOTHINGTOSEEHERE= but got %v", result[1])
	}
}
