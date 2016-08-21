package generator

import (
	"errors"
	"fmt"
	"path"
	"path/filepath"
	"sort"
	"strings"

	"github.com/golang/protobuf/proto"
	"github.com/golang/protobuf/protoc-gen-go/descriptor"
	plugin "github.com/golang/protobuf/protoc-gen-go/plugin"
	"github.com/sr/operator"
)

const (
	binaryParam     = "binary"
	importPathParam = "import_path"
	sourceField     = "source"
)

func describe(request *plugin.CodeGeneratorRequest) (*Descriptor, error) {
	numFiles := len(request.FileToGenerate)
	if numFiles == 0 {
		return nil, errors.New("no file to generate")
	}
	filesByName := make(map[string]*descriptor.FileDescriptorProto, numFiles)
	numServices := 0
	for _, f := range request.ProtoFile {
		for _, fn := range request.FileToGenerate {
			if f.GetName() == fn {
				numServices = numServices + len(f.Service)
				filesByName[f.GetName()] = f
			}
		}
	}
	params := make(map[string]string)
	for _, p := range strings.Split(request.GetParameter(), ",") {
		if i := strings.Index(p, "="); i < 0 {
			params[p] = ""
		} else {
			params[p[0:i]] = p[i+1:]
		}
	}
	importPathPrefix, ok := params[importPathParam]
	if !ok {
		return nil, fmt.Errorf("%s parameter is required", importPathParam)
	}
	binaryName := DefaultBinaryName
	if val, ok := params[binaryParam]; ok {
		binaryName = val
	}
	desc := &Descriptor{
		Options: &Options{
			BinaryName: binaryName,
		},
	}
	i := 0
	sort.Strings(request.FileToGenerate)
	for _, fileName := range request.FileToGenerate {
		file := filesByName[fileName]
		services := make([]*Service, len(file.Service))
		messagesByName := make(map[string]*descriptor.DescriptorProto)
		for _, message := range file.MessageType {
			messagesByName[message.GetName()] = message
		}
		for j, service := range file.Service {
			if service.Options == nil {
				return nil, fmt.Errorf("options name for service %s is missing", service.GetName())
			}
			name, err := proto.GetExtension(service.Options, operator.E_Name)
			if err != nil {
				return nil, err
			}
			nameStr := *name.(*string)
			fn := file.GetName()
			importPath := filepath.Join(importPathPrefix, strings.Replace(path.Base(fn), path.Ext(fn), "", -1))
			services[j] = &Service{
				Name:        nameStr,
				FullName:    service.GetName(),
				Description: undocumentedPlaceholder,
				Methods:     make([]*Method, len(service.Method)),
				// TODO(sr) might have to handle go_package proto option as well
				PackageName: file.GetPackage(),
				ImportPath:  importPath,
			}
			if m, ok := messagesByName[service.GetName()+"Config"]; ok {
				services[j].Config = make([]Setting, len(m.Field))
				for i, f := range m.Field {
					services[j].Config[i] = Setting{
						Name:        f.GetName(),
						Description: "",
						Required:    true,
					}
				}
			} else {
				services[j].Config = make([]Setting, 0)
			}
			for k, method := range service.Method {
				inputName := strings.Split(method.GetInputType(), ".")[2]
				outputName := strings.Split(method.GetOutputType(), ".")[2]
				input, ok := messagesByName[inputName]
				if !ok {
					return nil, fmt.Errorf("No definition for input message %s", inputName)
				}
				if err := validateMessageHasField(input, sourceField); err != nil {
					return nil, err
				}
				if method.GetOutputType() != ".operator.Response" {
					output, ok := messagesByName[outputName]
					if !ok {
						return nil, fmt.Errorf("No definition for output message %s", outputName)
					}
					if len(output.Field) == 0 {
						return nil, fmt.Errorf("Output message '%s' has no field", output.GetName())
					}
					var field *descriptor.FieldDescriptorProto
					ok = false
					for _, f := range output.Field {
						if f.GetNumber() == 1 {
							ok = true
							field = f
						}
					}
					if !ok {
						return nil, fmt.Errorf("Output message '%s' has no field with ID = %d", output.GetName(), 1)
					}
					if field.GetType() != descriptor.FieldDescriptorProto_TYPE_STRING {
						return nil, fmt.Errorf("field %s.message must be a string", output.GetName())
					}
				}
				services[j].Methods[k] = &Method{
					Name:        method.GetName(),
					Description: undocumentedPlaceholder,
					Input:       inputName,
					Output:      outputName,
					Arguments:   make([]*Argument, len(input.Field)-1),
				}
				for l, field := range input.Field {
					if field.GetName() == sourceField {
						continue
					}
					services[j].Methods[k].Arguments[l-1] = &Argument{
						// TODO(sr) deal with ID => Id etc better
						Name:        strings.Replace(field.GetName(), "ID", "Id", 1),
						Description: undocumentedPlaceholder,
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
				services[loc.Path[1]].Description = clean(*loc.LeadingComments)
			} else if len(loc.Path) == 4 && loc.Path[0] == 6 && loc.Path[2] == 2 {
				s := services[loc.Path[1]]
				m := s.Methods[loc.Path[3]]
				m.Description = clean(*loc.LeadingComments)
			}
		}
		desc.Services = append(desc.Services, services...)
	}
	return desc, nil
}

func validateMessageHasField(
	msg *descriptor.DescriptorProto,
	fieldName string,
) error {
	if len(msg.Field) == 0 {
		return fmt.Errorf("Input message '%s' has no field", msg.GetName())
	}
	var field *descriptor.FieldDescriptorProto
	ok := false
	for _, f := range msg.Field {
		if f.GetNumber() == 1 {
			ok = true
			field = f
		}
	}
	fullName := fmt.Sprintf(".operator.%s", strings.Title(fieldName))
	if !ok || field.GetName() != fieldName || field.GetTypeName() != fullName {
		return fmt.Errorf(
			"Input message '%s' does not have a valid '%s' field",
			msg.GetName(),
			fieldName,
		)
	}
	return nil
}

func clean(s string) string {
	return strings.Trim(strings.Trim(s, " "), "\n")
}
