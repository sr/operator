package main

import (
	"fmt"
	"os"

	"github.com/sr/operator/src/gencmd"
	"github.com/sr/operator/src/generator"
)

func main() {
	if err := generator.Compile(os.Stdin, os.Stdout, gencmd.Generate); err != nil {
		fmt.Fprintf(os.Stderr, "protoc-gen-operatorcmd: %s\n", err)
		os.Exit(1)
	}
}
