package main

import (
	"bytes"
	"fmt"
	"os"

	"github.com/sr/operator/generator"
)

const (
	executable = "protoc-gen-operatord"
	filename   = "builder-gen.go"
)

func generate(descriptor *generator.Descriptor) ([]*generator.File, error) {
	var buffer bytes.Buffer
	if err := builderTemplate.Execute(&buffer, descriptor); err != nil {
		return nil, err
	}
	return []*generator.File{
		{
			Name:    filename,
			Content: buffer.String(),
		},
	}, nil
}

func main() {
	if err := generator.Compile(os.Stdin, os.Stdout, generate); err != nil {
		fmt.Fprintf(os.Stderr, "%s: %s\n", executable, err)
		os.Exit(1)
	}
}
