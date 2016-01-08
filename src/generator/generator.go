// Package generator generates Golang code from the input proto files (first
// normalized using the "descriptor" package) then compiles the code into
// protobuf structures for use by the protoc executable.
package generator

import (
	"fmt"
	"io"
	"io/ioutil"
	"text/template"

	"github.com/golang/protobuf/proto"
	plugin "github.com/golang/protobuf/protoc-gen-go/plugin"
	"github.com/sr/operator/src/descriptor"
)

type File struct {
	Name    string
	Content string
}

type Generator func(*descriptor.OperatorDesc) ([]*File, error)

func Compile(input io.Reader, output io.Writer, gen Generator) error {
	data, err := ioutil.ReadAll(input)
	if err != nil {
		return fmt.Errorf("failed to read input: %s", err)
	}
	request := &plugin.CodeGeneratorRequest{}
	if err := proto.Unmarshal(data, request); err != nil {
		return fmt.Errorf("failed to parse input proto: %s", err)
	}
	desc, err := descriptor.Describe(request)
	if err != nil {
		return fmt.Errorf("failed to normalize proto request: %s", err)
	}
	files, err := gen(desc)
	if err != nil {
		return fmt.Errorf("failed to generate files: %s", err)
	}
	response := &plugin.CodeGeneratorResponse{
		File: make([]*plugin.CodeGeneratorResponse_File, len(files)),
	}
	for i, file := range files {
		response.File[i] = new(plugin.CodeGeneratorResponse_File)
		response.File[i].Name = proto.String(file.Name)
		response.File[i].Content = proto.String(file.Content)
	}
	if err != nil {
		return fmt.Errorf("failed to generate proto response: %s", err)
	}
	data, err = proto.Marshal(response)
	if err != nil {
		return fmt.Errorf("failed to marshal proto response: %s", err)
	}
	_, err = output.Write(data)
	if err != nil {
		return fmt.Errorf("failed to write marshaled proto response: %s", err)
	}
	return nil
}

func NewTemplate(name string, content string) *template.Template {
	return template.Must(template.New(name).Funcs(template.FuncMap{
		"camelCase":     camelCase,
		"dasherize":     dasherize,
		"wrap":          wrap,
		"wrappedIndent": wrappedIndent,
	}).Parse(content))
}
