package genoperatord

import (
	"bytes"

	"github.com/sr/operator/src/descriptor"
	"github.com/sr/operator/src/generator"
)

const (
	fileName = "main-gen.go"
	// TODO: this should be dynamic and allow services to live outside of
	// the operator import path... perhaps through a FileOptions?
	baseImportPath = "github.com/sr/operator/src/services/%s"
	defaultAddress = "0.0.0.0:3000"
)

func Generate(descriptor *descriptor.OperatorDesc) ([]*generator.File, error) {
	var buffer bytes.Buffer
	if err := template.Execute(&buffer, descriptor); err != nil {
		return nil, err
	}
	response := []*generator.File{
		&generator.File{
			Name:    fileName,
			Content: buffer.String(),
		},
	}
	return response, nil
}
