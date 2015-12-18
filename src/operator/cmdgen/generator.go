package cmdgen

import (
	"bytes"
	"errors"
	"html"
	"strings"

	"github.com/golang/protobuf/proto"
	"github.com/golang/protobuf/protoc-gen-go/descriptor"
	plugin "github.com/golang/protobuf/protoc-gen-go/plugin"
	"github.com/sr/operator/src/operator"
)

const (
	defaultBinaryName       = "operator"
	undocumentedPlaceholder = "Undocumented."
)

type generator struct {
	request *plugin.CodeGeneratorRequest
}

type mainDescriptor struct {
	BinaryName string
	Services   []*serviceDescriptor
}

type serviceDescriptor struct {
	Name        string
	Description []string
	Methods     []*methodDescriptor
}

type methodDescriptor struct {
	Name        string
	Description string
	Arguments   []*argumentDescriptor
}

type argumentDescriptor struct {
	Name        string
	Description string
}

func newGenerator(request *plugin.CodeGeneratorRequest) *generator {
	return &generator{request}
}

func (g *generator) Generate() (*plugin.CodeGeneratorResponse, error) {
	numFiles := len(g.request.FileToGenerate)
	if numFiles == 0 {
		return nil, errors.New("no file to generate")
	}
	params := make(map[string]string)
	for _, p := range strings.Split(g.request.GetParameter(), ",") {
		if i := strings.Index(p, "="); i < 0 {
			params[p] = ""
		} else {
			params[p[0:i]] = p[i+1:]
		}
	}
	binaryName := defaultBinaryName
	if val, ok := params["binary"]; ok {
		binaryName = val
	}
	main := &mainDescriptor{BinaryName: binaryName}
	for _, file := range g.request.ProtoFile {
		messagesByName := make(map[string]*descriptor.DescriptorProto)
		for _, message := range file.MessageType {
			messagesByName[message.GetName()] = message
		}
		main.Services = make([]*serviceDescriptor, len(file.Service))
		for i, service := range file.Service {
			name, err := proto.GetExtension(service.Options, operator.E_Name)
			if err != nil {
				return nil, err
			}
			main.Services[i] = &serviceDescriptor{
				Name:        *name.(*string),
				Description: []string{undocumentedPlaceholder},
				Methods:     make([]*methodDescriptor, len(service.Method)),
			}
			for j, method := range service.Method {
				input := messagesByName[strings.Split(method.GetInputType(), ".")[2]]
				main.Services[i].Methods[j] = &methodDescriptor{
					Name:        method.GetName(),
					Description: undocumentedPlaceholder,
					Arguments:   make([]*argumentDescriptor, len(input.Field)),
				}
				for k, field := range input.Field {
					main.Services[i].Methods[j].Arguments[k] = &argumentDescriptor{
						Name:        field.GetName(),
						Description: undocumentedPlaceholder,
					}
				}
			}
		}
		for _, loc := range file.GetSourceCodeInfo().GetLocation() {
			if loc.LeadingComments == nil {
				continue
			}
			if len(loc.Path) == 2 && loc.Path[0] == 6 {
				main.Services[loc.Path[1]].Description = strings.Split(strings.Replace(*loc.LeadingComments, `\'`, "'", -1), "\n")
			} else if len(loc.Path) == 4 && loc.Path[0] == 6 && loc.Path[2] == 2 {
				main.Services[loc.Path[1]].Methods[loc.Path[3]].Description = *loc.LeadingComments
			}
		}
	}
	var buffer bytes.Buffer
	if err := mainTemplate.Execute(&buffer, main); err != nil {
		return nil, err
	}
	response := &plugin.CodeGeneratorResponse{}
	response.File = make([]*plugin.CodeGeneratorResponse_File, 1)
	response.File[0] = &plugin.CodeGeneratorResponse_File{
		Name:    proto.String("main-gen.go"),
		Content: proto.String(html.UnescapeString(buffer.String())),
	}
	return response, nil
}
