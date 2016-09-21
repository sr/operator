// Package generator generates Golang code from the input proto files then
// compiles the code into protobuf structures for use by the protoc executable.
package generator

import (
	"fmt"
	"go/format"
	"io"
	"io/ioutil"
	"path/filepath"
	"text/template"

	plugin "github.com/golang/protobuf/protoc-gen-go/plugin"

	"github.com/golang/protobuf/proto"
)

const (
	DefaultBinaryName       = "operator"
	undocumentedPlaceholder = "Undocumented."
)

type Descriptor struct {
	Options  *Options
	Imports  map[string]string
	Services []*Service
}

type Options struct {
	BinaryName     string
	DefaultAddress string
}

type Service struct {
	Name        string
	FullName    string
	Description string
	Package     string
	Methods     []*Method
	Config      []Setting
}

type Setting struct {
	Name        string
	Required    bool
	Description string
}

type Method struct {
	Name        string
	Description string
	Input       string
	Output      string
	Arguments   []*Argument
}

type Argument struct {
	Name        string
	Description string
}

type File struct {
	Name    string
	Content string
}

type Generator func(*Descriptor) ([]*File, error)

func Compile(input io.Reader, output io.Writer, gen Generator) error {
	data, err := ioutil.ReadAll(input)
	if err != nil {
		return fmt.Errorf("failed to read input: %s", err)
	}
	request := &plugin.CodeGeneratorRequest{}
	if err := proto.Unmarshal(data, request); err != nil {
		return fmt.Errorf("failed to parse input proto: %s", err)
	}
	desc, err := describe(request)
	if err != nil {
		return fmt.Errorf("could not parse proto request: %s", err)
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
		if filepath.Ext(file.Name) == ".go" {
			s, err := format.Source([]byte(file.Content))
			if err != nil {
				return fmt.Errorf("could not gofmt generated code: %v", err)
			}
			response.File[i].Content = proto.String(string(s))
		} else {
			response.File[i].Content = proto.String(file.Content)
		}
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
	return template.Must(template.New(name).Funcs(funcMap).Parse(content))
}
