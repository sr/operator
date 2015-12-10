package cmd

import (
	"fmt"
	"strings"

	google_protobuf "github.com/gogo/protobuf/protoc-gen-gogo/descriptor"
	"github.com/gogo/protobuf/protoc-gen-gogo/generator"
)

const operatorPkgPrefix = "github.com/sr/operator/src/services"

type cmd struct {
	*generator.Generator
	generator.PluginImports
	contextPkg       generator.Single
	flagPkg          generator.Single
	grpcPkg          generator.Single
	messagesByName   map[string]*google_protobuf.DescriptorProto
	osPkg            generator.Single
	pkgPkg           generator.Single
	protoPkg         generator.Single
	protoPackageName string
	protoServiceName string
}

func New() *cmd {
	return &cmd{}
}

func (p *cmd) Name() string {
	return "cmd"
}

func (c *cmd) generateHeader() {
	c.P("x")
}

func (p *cmd) PackageName() string {
	return "main"
}

func (p *cmd) Init(g *generator.Generator) {
	p.Generator = g
}

func (c *cmd) Generate(file *generator.FileDescriptor) {
	c.PluginImports = generator.NewPluginImports(c.Generator)
	if len(file.FileDescriptorProto.Service) == 0 {
		return
	}
	if len(file.FileDescriptorProto.Service) > 1 {
		panic("can not generate command for more than one service")
	}
	c.protoPackageName = *file.FileDescriptorProto.Package
	c.setupImports()
	c.messagesByName = make(map[string]*google_protobuf.DescriptorProto)
	for _, message := range file.FileDescriptorProto.MessageType {
		c.messagesByName[*message.Name] = message
	}
	service := file.FileDescriptorProto.Service[0]
	c.protoServiceName = *service.Name
	c.generateService(file.FileDescriptorProto, service)
	c.P("")
	c.generateHandleMethod(file.FileDescriptorProto.Service[0])
	c.P("")
	c.generateMain()
}

func (c *cmd) setupImports() {
	c.contextPkg = c.NewImport("golang.org/x/net/context")
	c.flagPkg = c.NewImport("flag")
	c.pkgPkg = c.NewImport(fmt.Sprintf("%s/%s", operatorPkgPrefix, c.protoPackageName))
	c.grpcPkg = c.NewImport("google.golang.org/grpc")
	c.osPkg = c.NewImport("os")
	c.protoPkg = c.NewImport("github.com/sr/operator/src/proto")
}

func (c *cmd) generateService(
	file *google_protobuf.FileDescriptorProto,
	service *google_protobuf.ServiceDescriptorProto,
) {

	c.P("const commandName = \"", file.Package, "\"")
	c.P("")
	c.P("type serviceCommand struct {")
	c.In()
	c.P("client ", c.pkgPkg.Use(), ".", service.Name, "Client")
	c.Out()
	c.P("}")
	c.P("")
	c.P("func newServiceCommand(client ", c.pkgPkg.Use(), ".", service.Name,
		"Client) *serviceCommand {")
	c.In()
	c.P("return &serviceCommand{client}")
	c.Out()
	c.P("}")

	for _, method := range service.Method {
		c.P("")
		c.generateMethod(method)
	}
}

func (c *cmd) getMessage(name string) *google_protobuf.DescriptorProto {
	if val, ok := c.messagesByName[name]; ok {
		return val
	} else {
		// TODO
		panic(fmt.Sprintf("%v", name))
	}
}

func (c *cmd) generateMethod(method *google_protobuf.MethodDescriptorProto) {
	src := fmt.Sprintf(".%s.", c.protoPackageName)
	message := c.getMessage(strings.Replace(*method.InputType, src, "", 1))
	c.P("func (s *serviceCommand) ", method.Name, "() (*", c.protoPkg.Use(), ".Output, error) {")
	c.In()
	c.P("flags := ", c.flagPkg.Use(), ".NewFlagSet(", "\"", method.Name, "\", flag.ExitOnError)")
	for _, field := range message.Field {
		c.P(field.Name, " := ", `flags.String("`, field.Name, `", "", "")`)
		c.P("flags.Parse(", c.osPkg.Use(), ".Args[2:])")
	}
	c.P("response, err := s.client.", method.Name, "(")
	c.In()
	c.P(c.contextPkg.Use(), ".Background(), ")
	src = fmt.Sprintf(".%s", c.protoPackageName)
	structName := strings.Replace(*method.InputType, src, "", 1)
	c.P("&", c.pkgPkg.Use(), structName, "{")
	c.In()
	for _, field := range message.Field {
		c.P(generator.CamelCase(*field.Name), ": *", field.Name, ",")
	}
	c.Out()
	c.P("},")
	c.Out()
	c.P(")")
	c.P("if err != nil {")
	c.In()
	c.P("return nil, err")
	c.Out()
	c.P("}")
	c.P("return response.Output, nil")
	c.Out()
	c.P("}")
}

func (c *cmd) generateHandleMethod(
	service *google_protobuf.ServiceDescriptorProto,
) {
	c.P("func (s *serviceCommand) handle(method string) (*", c.protoPkg.Use(), ".Output, error) {")
	c.In()
	c.P("switch method {")
	for _, method := range service.Method {
		c.P(`case "`, method.Name, `":`)
		c.In()
		c.P("return s.", method.Name, "()")
		c.Out()
		c.P("default:")
		c.In()
		c.P(`return nil, fmt.Errorf("unspported method: %s", method)`)
		c.Out()
		c.P("}")
	}
	c.Out()
	c.P("}")
}

func (c *cmd) generateMain() {
	c.P("func main() {")
	c.In()
	c.P("conn, err := ", c.grpcPkg.Use(), `.Dial(":3000", `, c.grpcPkg.Use(), ".WithInsecure())")
	c.P("if err != nil {")
	c.In()
	c.P("panic(err)")
	c.Out()
	c.P("}")
	c.P("defer conn.Close()")
	c.P("if len(", c.osPkg.Use(), ".Args) < 2 {")
	c.In()
	c.P("fmt.Fprintf(", c.osPkg.Use(), `.Stderr, "Usage: %s <service> \n", commandName)`)
	c.P("os.Exit(1)")
	c.Out()
	c.P("}")
	c.P("client := ", c.pkgPkg.Use(), ".New", c.protoServiceName, "Client(conn)")
	c.P("service := newServiceCommand(client)")
	c.P("method := ", c.osPkg.Use(), ".Args[1]")
	c.P("output, err := service.handle(method)")
	c.P("if err != nil {")
	c.In()
	c.P("fmt.Fprintf(", c.osPkg.Use(), `.Stderr, "%v\n", err)`)
	c.P(c.osPkg.Use(), ".Exit(1)")
	c.Out()
	c.P("}")
	c.P("fmt.Fprintln(os.Stdout, output.PlainText)")
	c.Out()
	c.P("}")
}
