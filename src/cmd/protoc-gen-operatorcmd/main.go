package main

import (
	"bytes"
	"fmt"
	"os"

	"github.com/sr/operator/src/descriptor"
	"github.com/sr/operator/src/generator"
)

const (
	executable = "protoc-gen-operatorcmd"
	fileName   = "main-gen.go"
)

type serviceUsageContext struct {
	BinaryName string
	Service    *descriptor.Service
}

type mainContext struct {
	*descriptor.OperatorDesc
	MainUsage    string
	ServiceUsage map[string]string
}

func generate(descriptor *descriptor.OperatorDesc) ([]*generator.File, error) {
	var buffer bytes.Buffer
	context := &mainContext{
		descriptor,
		"",
		make(map[string]string, len(descriptor.Services)),
	}
	if err := mainUsageTemplate.Execute(&buffer, descriptor); err != nil {
		return nil, err
	}
	context.MainUsage = buffer.String()
	for _, service := range descriptor.Services {
		serviceContext := &serviceUsageContext{
			BinaryName: descriptor.Options.BinaryName,
			Service:    service,
		}
		buffer.Reset()
		if err := serviceUsageTemplate.Execute(&buffer, serviceContext); err != nil {
			return nil, err
		}
		context.ServiceUsage[service.Name] = buffer.String()
	}
	buffer.Reset()
	if err := mainTemplate.Execute(&buffer, context); err != nil {
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
		fmt.Fprintf(os.Stderr, "%s: %s\n", executable, err)
		os.Exit(1)
	}
}
