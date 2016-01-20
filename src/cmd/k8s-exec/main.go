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
	for _, secret := range os.Args[2:] {
		fileName := fmt.Sprintf(
			"/secrets/%s",
			strings.Replace(strings.ToLower(secret), "_", ".", -1),
		)
		value, err := ioutil.ReadFile(fileName)
		if err != nil {
			return fmt.Errorf("open-file secret=%s file=%s err=%v", secret, fileName, err)
		}
		if err := os.Setenv(secret, string(value)); err != nil {
			return fmt.Errorf("set-env secret=%s file=%s err=%v", secret, fileName, err)
		}
		fmt.Fprintf(os.Stderr, "set-env secret=%s file=%s", secret, fileName)
	}
	return syscall.Exec(os.Args[1], []string{os.Args[1]}, []string{})
}

func main() {
	if err := run(); err != nil {
		fmt.Fprintf(os.Stderr, "k8s-exec: %v", err)
		os.Exit(1)
	}
}
