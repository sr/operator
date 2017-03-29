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
	importPathParam = "import_path"
	sourceField     = "request"
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
	desc := &Descriptor{Imports: map[string]string{}}
	i := 0
	sort.Strings(request.FileToGenerate)
	for _, fileName := range request.FileToGenerate {
		file := filesByName[fileName]
		services := make([]*Service, len(file.Service))
		messagesByName := make(map[string]*descriptor.DescriptorProto)
		messagesIdxByName := make(map[string]int)
		for i, message := range file.MessageType {
			messagesByName[message.GetName()] = message
			messagesIdxByName[message.GetName()] = i
		}
		for j, service := range file.Service {
			pkg := file.GetPackage()
			// Check for overriden go package
			if gopkg := file.GetOptions().GetGoPackage(); gopkg != "" {
				pkg = gopkg
			}
			fn := file.GetName()
			if _, ok := desc.Imports[pkg]; !ok {
				desc.Imports[pkg] = filepath.Join(importPathPrefix, path.Dir(fn))
			}
			services[j] = &Service{
				Name:        service.GetName(),
				Package:     pkg,
				Description: undocumentedPlaceholder,
				Methods:     make([]*Method, len(service.Method)),
			}
			// Check the status of the "operator.enabled" boolan option for the service
			if service.Options != nil {
				opt, err := proto.GetExtension(service.Options, operator.E_Enabled)
				if err == nil {
					if v, ok := opt.(*bool); ok {
						services[j].Enabled = *v
					}
				}
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
				services[j].Methods[k] = &Method{
					Name:        method.GetName(),
					Description: undocumentedPlaceholder,
				}
				if !services[j].Enabled {
					continue
				}
				inputName := strings.Split(method.GetInputType(), ".")[2]
				outputName := strings.Split(method.GetOutputType(), ".")[2]
				services[j].Methods[k].Input = inputName
				services[j].Methods[k].Output = outputName
				input, ok := messagesByName[inputName]
				if ok {
					services[j].Methods[k].Arguments = make([]*Argument, len(input.Field))
				} else {
					services[j].Methods[k].Arguments = make([]*Argument, 0)
				}
				if input != nil {
					for l, field := range input.Field {
						services[j].Methods[k].Arguments[l] = &Argument{
							Name:        field.GetName(),
							Type:        field.GetType(),
							Description: undocumentedPlaceholder,
							fieldNum:    *field.Number,
							messageIdx:  messagesIdxByName[input.GetName()],
						}
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
				// message_type && service
				services[loc.Path[1]].Description = clean(*loc.LeadingComments)
			} else if len(loc.Path) == 4 && loc.Path[0] == 6 && loc.Path[2] == 2 {
				// field declaration && service && field
				s := services[loc.Path[1]]
				m := s.Methods[loc.Path[3]]
				m.Description = clean(*loc.LeadingComments)
			} else if len(loc.Path) == 4 && loc.Path[0] == 4 && loc.Path[2] == 2 {
				// field declaration && message_type && field
				for _, s := range services {
					for _, m := range s.Methods {
						for _, a := range m.Arguments {
							// need the number of the field (loc[3]) and it's enclosing message?
							if a.messageIdx == int(loc.Path[1]) && a.fieldNum-1 == loc.Path[3] {
								a.Description = clean(*loc.LeadingComments)
							}
						}
					}
				}
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
