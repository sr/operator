package main

import (
	"bytes"
	"fmt"
	"os"

	"generator"
)

const (
	executable = "protoc-gen-operatorhubot"
	fileExt    = "coffee"
)

type serviceDescriptor struct {
	*generator.Service
}

func generate(descriptor *generator.Descriptor) ([]*generator.File, error) {
	var buffer bytes.Buffer
	response := make([]*generator.File, len(descriptor.Services))
	for i, service := range descriptor.Services {
		if err := template.Execute(&buffer, service); err != nil {
			return nil, err
		}
		response[i] = &generator.File{
			Name:    fmt.Sprintf("%s-gen.%s", service.Name, fileExt),
			Content: buffer.String(),
		}
		buffer.Reset()
	}
	return response, nil
}

func main() {
	if err := generator.Compile(os.Stdin, os.Stdout, generate); err != nil {
		fmt.Fprintf(os.Stderr, "%s: %s\n", executable, err)
		os.Exit(1)
	}
}
