package grpc_cmd

import (
	"fmt"

	"github.com/gogo/protobuf/protoc-gen-gogo/generator"
)

type grpcCmd struct {
	gen *generator.Generator
}

func (g *grpcCmd) Generate(file *generator.FileDescriptor) {
	if len(file.FileDescriptorProto.Service) == 0 {
		return
	}
	for i, service := range file.FileDescriptorProto.Service {
		fmt.Println("// service: ", file, i, service)
	}
}
