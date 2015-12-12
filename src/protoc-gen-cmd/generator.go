package cmd

import (
	"bytes"
	"errors"
	"fmt"
	"strings"
	"unicode"
	"unicode/utf8"

	"github.com/acsellers/inflections"
	"github.com/gogo/protobuf/proto"
	google_protobuf "github.com/gogo/protobuf/protoc-gen-gogo/descriptor"
	plugin "github.com/gogo/protobuf/protoc-gen-gogo/plugin"
	"github.com/serenize/snaker"
)

type generator struct {
	request *plugin.CodeGeneratorRequest
}

func newGenerator(request *plugin.CodeGeneratorRequest) *generator {
	return &generator{request}
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
			Name:    proto.String(fmt.Sprintf("%s/%s", name, MainGenFile)),
			Content: proto.String(content),
		}
	}
	return response, nil
}

func (g *generator) generateFile(
	file *google_protobuf.FileDescriptorProto,
) (name string, content string, err error) {
	if len(file.Service) != 1 {
		return "", "", errors.New("can only generate command for exactly one service")
	}
	service := file.Service[0]
	serviceCommand := &serviceCommandDescriptor{
		// TODO(sr) allow this to be outside of operator import path
		ServiceImportPath: fmt.Sprintf("%s/%s", ServicesImportPath, file.GetPackage()),
		CommandName:       file.GetPackage(),
		ServiceClient:     fmt.Sprintf("%sClient", service.GetName()),
		Methods:           make([]*methodDescriptor, len(service.Method)),
	}
	messagesByName := make(map[string]*google_protobuf.DescriptorProto, len(file.MessageType))
	for _, message := range file.MessageType {
		messagesByName[message.GetName()] = message
	}
	for i, method := range service.Method {
		methodDescriptor, err := g.newMethodDescriptor(
			file.GetPackage(),
			messagesByName[strings.Split(method.GetInputType(), ".")[2]],
			method,
		)
		if err != nil {
			return "", "", err
		}
		serviceCommand.Methods[i] = methodDescriptor
	}
	var buffer bytes.Buffer
	if err := commandTemplate.Execute(&buffer, serviceCommand); err != nil {
		return "", "", err
	}
	return file.GetPackage(), buffer.String(), nil
}

func (g *generator) newMethodDescriptor(
	packageName string,
	inputMessage *google_protobuf.DescriptorProto,
	method *google_protobuf.MethodDescriptorProto,
) (*methodDescriptor, error) {
	snakeCaseName := snaker.CamelToSnake(method.GetName())
	arguments := make([]*argumentDescriptor, len(inputMessage.Field))
	for i, field := range inputMessage.Field {
		arguments[i] = &argumentDescriptor{
			// TODO(sr) use same snake casing algo as grpc (i.e. don't repect accronyms)
			CamelCaseName:  strings.Replace(snaker.SnakeToCamel(field.GetName()), "ID", "Id", 1),
			SnakeCaseName:  lowerFirst(snaker.SnakeToCamel(field.GetName())),
			DasherizedName: inflections.Dasherize(field.GetName()),
		}
	}
	return &methodDescriptor{
		Name:           method.GetName(),
		SnakeCasedName: snakeCaseName,
		DasherizedName: inflections.Dasherize(snakeCaseName),
		Arguments:      arguments,
		Input:          inputMessage.GetName(),
	}, nil
}

func lowerFirst(s string) string {
	r, n := utf8.DecodeRuneInString(s)
	return string(unicode.ToLower(r)) + s[n:]
}
