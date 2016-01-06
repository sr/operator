package main

import (
	"fmt"
	"os"

	"github.com/sr/operator/src/generator"
	"github.com/sr/operator/src/genoperatord"
)

func main() {
	if err := generator.Compile(os.Stdin, os.Stdout, genoperatord.Generate); err != nil {
		fmt.Fprintf(os.Stderr, "%s\n", err)
		os.Exit(1)
	}
}
