package main

import (
	"bytes"
	"fmt"
	"os"

	"github.com/sr/operator/generator"
)

const (
	executable = "protoc-gen-operatorhubot"
	fileExt    = "coffee"
)

type serviceDescriptor struct {
	*generator.Service
	Args map[string]string
}

func generate(descriptor *generator.Descriptor) ([]*generator.File, error) {
	var (
		buffer     bytes.Buffer
		argsBuffer bytes.Buffer
	)
	response := make([]*generator.File, len(descriptor.Services))
	for i, service := range descriptor.Services {
		context := &serviceDescriptor{Service: service, Args: make(map[string]string)}
		for _, method := range service.Methods {
			for _, arg := range method.Arguments {
				_, err := argsBuffer.WriteString(fmt.Sprintf(" [%s=value]", arg.Name))
				if err != nil {
					return nil, err
				}
			}
			context.Args[method.Name] = argsBuffer.String()
			argsBuffer.Reset()
		}
		if err := template.Execute(&buffer, context); err != nil {
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
