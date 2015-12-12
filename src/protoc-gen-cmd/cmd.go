package cmd

import plugin "github.com/gogo/protobuf/protoc-gen-gogo/plugin"

const (
	ServicesImportPath = "github.com/sr/operator/src/services"
	MainGenFile        = "main-gen.go"
)

type Generator interface {
	Generate() (*plugin.CodeGeneratorResponse, error)
}

func NewGenerator(request *plugin.CodeGeneratorRequest) Generator {
	return newGenerator(request)
}
