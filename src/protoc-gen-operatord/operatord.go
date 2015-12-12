package operatord

import plugin "github.com/gogo/protobuf/protoc-gen-gogo/plugin"

type Generator interface {
	Generate() (*plugin.CodeGeneratorResponse, error)
}

func NewGenerator(request *plugin.CodeGeneratorRequest) Generator {
	return newGenerator(request)
}
