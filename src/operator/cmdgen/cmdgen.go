package cmdgen

import plugin "github.com/golang/protobuf/protoc-gen-go/plugin"

type Generator interface {
	Generate() (*plugin.CodeGeneratorResponse, error)
}

func NewGenerator(request *plugin.CodeGeneratorRequest) Generator {
	return newGenerator(request)
}
