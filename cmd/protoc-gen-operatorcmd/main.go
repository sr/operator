package main

import (
	"bytes"
	"fmt"
	"os"

	"github.com/sr/operator/generator"
)

const (
	programName = "protoc-gen-operatorcmd"
	fileName    = "main-gen.go"
)

func generate(descriptor *generator.Descriptor) ([]*generator.File, error) {
	var buffer bytes.Buffer
	if err := mainTemplate.Execute(&buffer, descriptor); err != nil {
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
		fmt.Fprintf(os.Stderr, "%s: %s\n", programName, err)
		os.Exit(1)
	}
}
