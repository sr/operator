package main

import (
	"errors"
	"fmt"
	"io/ioutil"
	"os"
	"strings"
	"syscall"
)

func run() error {
	if len(os.Args) < 2 {
		return errors.New("Usage: k8s-exec <executable> <secret-name>...")
	}
	var env []string
	for _, secret := range os.Args[2:] {
		fileName := fmt.Sprintf(
			"/secrets/%s",
			strings.Replace(strings.ToLower(secret), "_", ".", -1),
		)
		value, err := ioutil.ReadFile(fileName)
		if err != nil {
			return fmt.Errorf("k8s-exec: open-file secret=%s file=%s err=%v", secret, fileName, err)
		}
		env = append(env, fmt.Sprintf("%s=%s", secret, string(value)))
	}
	return syscall.Exec(os.Args[1], []string{os.Args[1]}, env)
}

func main() {
	if err := run(); err != nil {
		fmt.Fprintf(os.Stderr, "k8s-exec: %v", err)
		os.Exit(1)
	}
}
