package cmd

import (
	"fmt"
	"strings"

	"github.com/gogo/protobuf/protoc-gen-gogo/descriptor"
	"github.com/gogo/protobuf/protoc-gen-gogo/generator"
)

const operatorPkgPrefix = "github.com/sr/operator/src"

type cmd struct {
	*generator.Generator
	generator.PluginImports
	gcloudPkg      generator.Single
	protoPkg       generator.Single
	contextPkg     generator.Single
	grpcPkg        generator.Single
	messagesByName map[string]*google_protobuf.DescriptorProto
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

	c.setupImports()

	c.messagesByName = make(map[string]*google_protobuf.DescriptorProto)
	for _, message := range file.FileDescriptorProto.MessageType {
		c.messagesByName[*message.Name] = message
	}

	for _, service := range file.FileDescriptorProto.Service {
		c.generateService(file.FileDescriptorProto, service)
	}

	c.P("")
	c.generateHandleMethod(file.FileDescriptorProto.Service[0])
	c.P("")
	c.generateMain()
}

func (c *cmd) setupImports() {
	c.gcloudPkg = c.NewImport(fmt.Sprintf("%s/%s", operatorPkgPrefix, "gcloud"))
	c.contextPkg = c.NewImport("golang.org/x/net/context")
	c.grpcPkg = c.NewImport("google.golang.org/grpc")
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
	c.P("client ", c.gcloudPkg.Use(), ".", service.Name, "Client")
	c.Out()
	c.P("}")
	c.P("")
	c.P("func newServiceCommand(client ", c.gcloudPkg.Use(), ".", service.Name,
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
	message := c.getMessage(strings.Replace(*method.InputType, ".gcloud.", "", 1))

	c.P("func (s *serviceCommand) ", method.Name, "() (*", c.protoPkg.Use(), ".Output, error) {")
	c.In()
	c.P("flags := flag.NewFlagSet(", "\"", method.Name, "\", flag.ExitOnError)")
	for _, field := range message.Field {
		c.P(field.Name, " := flags.String(\"", field.Name, "\", \"\", \"\")")
		c.P("flags.Parse(os.Args[2:])")
	}
	c.P("response, err := s.client.", method.Name, "(")
	c.In()
	c.P(c.contextPkg.Use(), ".Background(), ")
	c.P(c.gcloudPkg.Use(), strings.Replace(*method.InputType, ".gcloud", "", 1), "{")
	c.In()
	for _, field := range message.Field {
		c.P(field.Name, ": ", field.Name, ",")
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
		c.P("case \"", method.Name, "\":")
		c.In()
		c.P("return s.", method.Name, "()")
		c.Out()
		c.P("default:")
		c.In()
		c.P("return nil, fmt.Errorf(\"unspported method: %%s\", method)")
		c.Out()
		c.P("}")
	}
	c.Out()
	c.P("}")
}

func (c *cmd) generateMain() {
	c.P(`
func main() {
	conn, err := grpc.Dial(":3000", grpc.WithInsecure())
	if err != nil {
		log.Fatal(err)
	}
	defer conn.Close()

	if len(os.Args) < 2 {
		fmt.Fprintf(os.Stderr, "Usage: %s <service> \n", commandName)
		os.Exit(1)
	}

	client := gcloud.NewGCloudServiceClient(conn)
	service := newServiceCommand(client)
	method := os.Args[1]

	output, err := service.handle(method)
	if err != nil {
		fmt.Fprintf(os.Stderr, "%v", err)
		os.Exit(1)
	}

	fmt.Fprintln(os.Stdout, output.PlainText)
}
`)
}
