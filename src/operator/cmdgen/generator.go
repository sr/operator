package cmdgen

import (
	"bytes"
	"errors"
	"fmt"
	"path"
	"strings"

	"github.com/acsellers/inflections"
	"github.com/golang/protobuf/proto"
	"github.com/golang/protobuf/protoc-gen-go/descriptor"
	plugin "github.com/golang/protobuf/protoc-gen-go/plugin"
	"github.com/kr/text"
	"github.com/serenize/snaker"
	"github.com/sr/operator/src/operator"
)

const (
	defaultBinaryName       = "operator"
	undocumentedPlaceholder = "  Undocumented."
)

type generator struct {
	request *plugin.CodeGeneratorRequest
}

type mainDescriptor struct {
	BinaryName string
	Services   []*serviceDescriptor
	Imports    []string
}

type serviceDescriptor struct {
	Name        string
	Description string
	BinaryName  string
	Methods     []*methodDescriptor
}

type methodDescriptor struct {
	Name           string
	NameDasherized string
	ServiceName    string
	Description    string
	ServiceClient  string
	ServicePkg     string
	Input          string
	Arguments      []*argumentDescriptor
}

type argumentDescriptor struct {
	Name           string
	NameCamelCase  string
	NameSnakeCase  string
	NameDasherized string
	Description    string
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
	numServices := 0
	for _, file := range g.request.ProtoFile {
		numServices = numServices + len(file.Service)
	}
	main := &mainDescriptor{
		BinaryName: binaryName,
		Imports:    make([]string, numFiles),
		Services:   make([]*serviceDescriptor, numServices),
	}
	for i, file := range g.request.FileToGenerate {
		// TODO(sr) substitute path.Ext() or whatever
		b := fmt.Sprintf("/%s", path.Base(file))
		main.Imports[i] = fmt.Sprintf("github.com/sr/operator/src/%s", strings.Replace(file, b, "", 1))
	}
	i := 0
	for _, file := range g.request.ProtoFile {
		messagesByName := make(map[string]*descriptor.DescriptorProto)
		for _, message := range file.MessageType {
			messagesByName[message.GetName()] = message
		}
		for _, service := range file.Service {
			if service.Options == nil {
				return nil, fmt.Errorf("options name for service %s is missing", service.GetName())
			}
			name, err := proto.GetExtension(service.Options, operator.E_Name)
			if err != nil {
				return nil, err
			}
			nameStr := *name.(*string)
			main.Services[i] = &serviceDescriptor{
				Name:        nameStr,
				BinaryName:  binaryName,
				Description: undocumentedPlaceholder,
				Methods:     make([]*methodDescriptor, len(service.Method)),
			}
			for j, method := range service.Method {
				input := messagesByName[strings.Split(method.GetInputType(), ".")[2]]
				main.Services[i].Methods[j] = &methodDescriptor{
					Name:           method.GetName(),
					Input:          input.GetName(),
					ServicePkg:     nameStr,
					ServiceClient:  fmt.Sprintf("%sClient", service.GetName()),
					NameDasherized: inflections.Dasherize(snaker.CamelToSnake(method.GetName())),
					Description:    undocumentedPlaceholder,
					Arguments:      make([]*argumentDescriptor, len(input.Field)),
				}
				for k, field := range input.Field {
					main.Services[i].Methods[j].Arguments[k] = &argumentDescriptor{
						// TODO(sr) deal with ID => Id etc better
						Name:           strings.Replace(snaker.SnakeToCamel(field.GetName()), "ID", "Id", 1),
						NameDasherized: inflections.Dasherize(snaker.CamelToSnake(field.GetName())),
						NameSnakeCase:  snaker.CamelToSnake(field.GetName()),
						Description:    undocumentedPlaceholder,
					}
				}
			}
			i = i + 1
		}
		for _, loc := range file.GetSourceCodeInfo().GetLocation() {
			if loc.LeadingComments == nil {
				continue
			}
			if len(loc.Path) == 2 && loc.Path[0] == 6 {
				main.Services[loc.Path[1]].Description = text.Indent(text.Wrap(*loc.LeadingComments, 80), "  ")
			} else if len(loc.Path) == 4 && loc.Path[0] == 6 && loc.Path[2] == 2 {
				main.Services[loc.Path[1]].Methods[loc.Path[3]].Description = text.Indent(text.Wrap(*loc.LeadingComments, 80), "  ")
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
		Content: proto.String(buffer.String()),
	}
	return response, nil
}
