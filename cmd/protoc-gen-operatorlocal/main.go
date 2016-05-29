package main

import (
	"bytes"
	"fmt"
	"os"

	"github.com/sr/operator/generator"
)

const (
	programName = "protoc-gen-operatorlocal"
)

func generate(descriptor *generator.Descriptor) ([]*generator.File, error) {
	var buffer bytes.Buffer
	response := make([]*generator.File, len(descriptor.Services))
	for i, service := range descriptor.Services {
		if err := clientTemplate.Execute(&buffer, service); err != nil {
			return nil, err
		}
		response[i] = &generator.File{
			Name:    service.PackageName + "client-gen.go",
			Content: buffer.String(),
		}
		buffer.Reset()
		if err := serverTemplate.Execute(&buffer, service); err != nil {
			return nil, err
		}
		response[i] = &generator.File{
			Name:    service.PackageName + "server-gen.go",
			Content: buffer.String(),
		}
		buffer.Reset()
	}
	return response, nil
}

func main() {
	if err := generator.Compile(os.Stdin, os.Stdout, generate); err != nil {
		fmt.Fprintf(os.Stderr, "%s: %s\n", programName, err)
		os.Exit(1)
	}
}
