package main

import (
	"bytes"
	"fmt"
	"os"

	"github.com/sr/operator/generator"
)

const (
	executable       = "protoc-gen-operatord"
	servicesFileName = "services-gen.go"
)

func generate(descriptor *generator.Descriptor) ([]*generator.File, error) {
	var buffer bytes.Buffer
	response := make([]*generator.File, len(descriptor.Services)+1)
	if err := servicesTemplate.Execute(&buffer, descriptor); err != nil {
		return nil, err
	}
	response[0] = &generator.File{
		Name:    servicesFileName,
		Content: buffer.String(),
	}
	for i, service := range descriptor.Services {
		buffer.Reset()
		if err := interceptorTemplate.Execute(&buffer, service); err != nil {
			return nil, err
		}
		response[i+1] = &generator.File{
			Name: fmt.Sprintf(
				"instrumented_%s-gen.go",
				service.PackageName,
			),
			Content: buffer.String(),
		}
	}
	return response, nil
}

func main() {
	if err := generator.Compile(os.Stdin, os.Stdout, generate); err != nil {
		fmt.Fprintf(os.Stderr, "%s: %s\n", executable, err)
		os.Exit(1)
	}
}
