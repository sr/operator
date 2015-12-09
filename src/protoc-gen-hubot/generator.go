package hubot

import (
	"errors"

	plugin "github.com/gogo/protobuf/protoc-gen-gogo/plugin"
)

type generator struct {
	request *plugin.CodeGeneratorRequest
}

func newGenerator(request *plugin.CodeGeneratorRequest) *generator {
	return &generator{request}
}

func (c *generator) Generate() (*plugin.CodeGeneratorResponse, error) {
	if len(c.request.FileToGenerate) == 0 {
		return nil, errors.New("no file to generate")
	}
	response := new(plugin.CodeGeneratorResponse)
	return response, nil
}
