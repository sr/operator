package main

import (
	"bytes"
	"fmt"
	"os"

	"github.com/sr/operator/src/generator"
)

const (
	executable = "protoc-gen-operatorcmd"
	fileName   = "main-gen.go"
)

type serviceUsageContext struct {
	BinaryName string
	Service    *generator.Service
}

type methodUsageContext struct {
	BinaryName  string
	Service     *generator.Service
	Name        string
	Description string
}

type mainContext struct {
	*generator.Descriptor
	MainUsage    string
	ServiceUsage map[string]string
	MethodUsage  map[string]map[string]string
}

func generate(descriptor *generator.Descriptor) ([]*generator.File, error) {
	var buffer bytes.Buffer
	context := &mainContext{
		descriptor,
		"",
		make(map[string]string, len(descriptor.Services)),
		make(map[string]map[string]string),
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
		context.MethodUsage[service.Name] = make(map[string]string, len(service.Methods))
		for _, method := range service.Methods {
			methodContext := &methodUsageContext{
				Service:     service,
				Name:        method.Name,
				Description: method.Description,
			}
			buffer.Reset()
			if err := methodUsageTemplate.Execute(&buffer, methodContext); err != nil {
				return nil, err
			}
			context.MethodUsage[service.Name][method.Name] = buffer.String()
		}
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
