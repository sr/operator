package hubot

import (
	"bytes"
	"errors"
	"fmt"
	"strings"

	"github.com/gogo/protobuf/proto"
	google_protobuf "github.com/gogo/protobuf/protoc-gen-gogo/descriptor"
	plugin "github.com/gogo/protobuf/protoc-gen-gogo/plugin"
)

type generator struct {
	request        *plugin.CodeGeneratorRequest
	messagesByName map[string]*google_protobuf.DescriptorProto
}

func newGenerator(request *plugin.CodeGeneratorRequest) *generator {
	return &generator{
		request,
		make(map[string]*google_protobuf.DescriptorProto),
	}
}

func (g *generator) Generate() (*plugin.CodeGeneratorResponse, error) {
	numFiles := len(g.request.FileToGenerate)
	if numFiles == 0 {
		return nil, errors.New("no file to generate")
	}
	response := &plugin.CodeGeneratorResponse{}
	response.File = make([]*plugin.CodeGeneratorResponse_File, numFiles)
	filesByName := make(map[string]*google_protobuf.FileDescriptorProto, numFiles)
	for _, file := range g.request.ProtoFile {
		filesByName[file.GetName()] = file
	}
	for i, fileName := range g.request.FileToGenerate {
		name, content, err := g.generateFile(filesByName[fileName])
		if err != nil {
			return nil, err
		}
		response.File[i] = &plugin.CodeGeneratorResponse_File{
			Name:    proto.String(fmt.Sprintf("%s.%s", name, "coffee")),
			Content: proto.String(content),
		}
	}
	return response, nil
}

func (g *generator) generateFile(
	protoFile *google_protobuf.FileDescriptorProto,
) (name string, content string, err error) {
	for _, message := range protoFile.MessageType {
		// TODO deal with message.Label (optional, required, repeated)
		// TODO deal with message.DefaultValue
		g.messagesByName[message.GetName()] = message
	}
	if len(protoFile.Service) != 1 {
		return "", "", errors.New("can only generate script for exactly one service")
	}
	service := protoFile.Service[0]
	var templateMethods []*templateMethod
	for _, method := range service.Method {
		templateMethod := g.newTemplateMethod(protoFile.GetPackage(), method)
		templateMethods = append(templateMethods, templateMethod)
	}
	var buffer bytes.Buffer
	data := &templateService{
		Package: protoFile.GetPackage(),
		Service: service.GetName(),
		Methods: templateMethods,
	}
	if err := scriptTemplate.Execute(&buffer, data); err != nil {
		return "", "", err
	}
	return protoFile.GetPackage(), buffer.String(), nil
}

func (g *generator) newTemplateMethod(
	service string,
	method *google_protobuf.MethodDescriptorProto,
) *templateMethod {
	inputMessage := g.messagesByName[strings.Split(method.GetInputType(), ".")[2]]
	arguments := bytes.NewBufferString("")
	for _, field := range inputMessage.Field {
		arguments.WriteString(fmt.Sprintf(" %s=(\\w+)", field.GetName()))
	}
	return &templateMethod{
		Service:   service,
		Name:      method.GetName(),
		NameLower: strings.ToLower(method.GetName()),
		Input:     strings.Split(method.GetInputType(), ".")[2],
		Arguments: arguments.String(),
	}
}
