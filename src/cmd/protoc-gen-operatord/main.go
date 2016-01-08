package main

import (
	"bytes"
	"fmt"
	"os"

	"github.com/sr/operator/src/descriptor"
	"github.com/sr/operator/src/generator"
)

const (
	fileName = "main-gen.go"
)

func generate(descriptor *descriptor.OperatorDesc) ([]*generator.File, error) {
	var buffer bytes.Buffer
	if err := template.Execute(&buffer, descriptor); err != nil {
		return nil, err
	}
	response := []*generator.File{
		{
			Name:    fileName,
			Content: buffer.String(),
		},
	}
	return response, nil
}

func main() {
	if err := generator.Compile(os.Stdin, os.Stdout, generate); err != nil {
		fmt.Fprintf(os.Stderr, "protoc-gen-operatord: %s\n", err)
		os.Exit(1)
	}
}
