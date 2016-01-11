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
	Args  map[string]string
	Input map[string]string
}

func generate(descriptor *generator.Descriptor) ([]*generator.File, error) {
	var buffer bytes.Buffer
	response := make([]*generator.File, len(descriptor.Services))
	for i, service := range descriptor.Services {
		args, input, err := generateMethodArgs(service)
		if err != nil {
			return nil, err
		}
		context := &serviceDescriptor{
			Service: service,
			Args:    args,
			Input:   input,
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

func generateMethodArgs(service *generator.Service) (
	map[string]string,
	map[string]string,
	error,
) {
	var (
		argsBuf  bytes.Buffer
		inputBuf bytes.Buffer
	)
	args := make(map[string]string, len(service.Methods))
	input := make(map[string]string, len(service.Methods))
	for _, method := range service.Methods {
		if _, err := inputBuf.WriteString("{"); err != nil {
			return nil, nil, err
		}
		for i, argument := range method.Arguments {
			arg := fmt.Sprintf(" %s=(\\w+)", argument.Name)
			if _, err := argsBuf.WriteString(arg); err != nil {
				return nil, nil, err
			}
			in := fmt.Sprintf("%s: msg.match[%d],", argument.Name, i+1)
			if _, err := inputBuf.WriteString(in); err != nil {
				return nil, nil, err
			}
		}
		args[method.Name] = argsBuf.String()
		argsBuf.Reset()
		inputBuf.WriteString("}")
		input[method.Name] = inputBuf.String()
		inputBuf.Reset()
	}
	return args, input, nil
}

func main() {
	if err := generator.Compile(os.Stdin, os.Stdout, generate); err != nil {
		fmt.Fprintf(os.Stderr, "%s: %s\n", executable, err)
		os.Exit(1)
	}
}
