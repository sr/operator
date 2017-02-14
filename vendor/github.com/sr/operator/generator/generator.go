// Package generator generates Golang code from the input proto files then
// compiles the code into protobuf structures for use by the protoc executable.
package generator

import (
	"fmt"
	"go/format"
	"io"
	"io/ioutil"
	"path/filepath"
	"strings"
	"text/template"
	"unicode"
	"unicode/utf8"

	plugin "github.com/golang/protobuf/protoc-gen-go/plugin"

	"github.com/golang/protobuf/proto"
)

const undocumentedPlaceholder = "Undocumented"

type Descriptor struct {
	Imports  map[string]string
	Services []*Service
}

type Service struct {
	Name        string
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

func Camelize(s string, sep string) string {
	var result string
	words := strings.Split(s, sep)
	for _, word := range words {
		if len(word) > 0 {
			w := []rune(word)
			w[0] = unicode.ToUpper(w[0])
			result += string(w)
		}
	}
	return result
}

var funcMap = template.FuncMap{
	"inputField":  func(s string) string { return Camelize(s, "_") },
	"serviceName": humanize,
	"methodName":  humanize,
	"argName":     humanize,
	"flagName":    humanize,
}

func humanize(str string) string {
	s := strings.Replace(camelToSnake(str), "_", "-", -1)
	r, n := utf8.DecodeRuneInString(s)
	return string(unicode.ToLower(r)) + s[n:]
}

func camelToSnake(s string) string {
	var (
		result  string
		words   []string
		lastPos int
	)
	rs := []rune(s)
	for i := 0; i < len(rs); i++ {
		if i > 0 && unicode.IsUpper(rs[i]) {
			words = append(words, s[lastPos:i])
			lastPos = i
		}
	}
	// append the last word
	if s[lastPos:] != "" {
		words = append(words, s[lastPos:])
	}
	for k, word := range words {
		if k > 0 {
			result += "_"
		}
		result += strings.ToLower(word)
	}
	return result
}
