package operatord

import (
	"bytes"
	"errors"
	"fmt"

	"github.com/gogo/protobuf/proto"
	google_protobuf "github.com/gogo/protobuf/protoc-gen-gogo/descriptor"
	plugin "github.com/gogo/protobuf/protoc-gen-gogo/plugin"
)

const (
	fileName = "main-gen.go"
	// TODO: this should be dynamic and allow services to live outside of
	// the operator import path... perhaps through a FileOptions?
	baseImportPath = "github.com/sr/operator/src/services/%s"
	defaultAddress = "0.0.0.0:3000"
)

type generator struct {
	request *plugin.CodeGeneratorRequest
}

func newGenerator(request *plugin.CodeGeneratorRequest) *generator {
	return &generator{request}
}

func (g *generator) Generate() (*plugin.CodeGeneratorResponse, error) {
	if len(g.request.FileToGenerate) == 0 {
		return nil, errors.New("no file to generate")
	}
	var services []*serviceDescriptor
	for _, file := range g.request.ProtoFile {
		for _, service := range file.Service {
			services = append(services, newServiceDescriptor(file, service))
		}
	}
	main := &mainDescriptor{Services: services, DefaultAddress: defaultAddress}
	var buffer bytes.Buffer
	if err := mainTemplate.Execute(&buffer, main); err != nil {
		return nil, err
	}
	response := &plugin.CodeGeneratorResponse{}
	response.File = make([]*plugin.CodeGeneratorResponse_File, 1)
	response.File[0] = new(plugin.CodeGeneratorResponse_File)
	response.File[0].Name = proto.String(fileName)
	response.File[0].Content = proto.String(buffer.String())
	return response, nil
}

func newServiceDescriptor(
	file *google_protobuf.FileDescriptorProto,
	service *google_protobuf.ServiceDescriptorProto,

) *serviceDescriptor {
	return &serviceDescriptor{
		CamelCaseName: service.GetName(),
		Name:          file.GetPackage(),
		ImportPath:    fmt.Sprintf(baseImportPath, file.GetPackage()),
		PackageName:   file.GetPackage(),
	}
}
