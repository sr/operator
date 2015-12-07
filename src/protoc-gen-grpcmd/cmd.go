package cmd

import (
	"fmt"

	"github.com/gogo/protobuf/protoc-gen-gogo/descriptor"
	"github.com/gogo/protobuf/protoc-gen-gogo/generator"
)

const operatorPkgPrefix = "github.com/sr/src/operator"

type cmd struct {
	*generator.Generator
	generator.PluginImports
	gcloudPkg generator.Single
	protoPkg generator.Single
	contextPkg generator.Single
	grpcPkg generator.Single
}

func New() *cmd {
	return &cmd{}
}

func (p *cmd) Name() string {
	return "cmd"
}

func (p *cmd) Init(g *generator.Generator) {
	p.Generator = g
}

func (c *cmd) Generate(file *generator.FileDescriptor) {
	c.PluginImports = generator.NewPluginImports(c.Generator)
	if len(file.FileDescriptorProto.Service) == 0 {
		return
	}

	c.setupImports()

	for _, service := range file.FileDescriptorProto.Service {
		c.generateService(file.FileDescriptorProto, service)
	}
}

func (c *cmd) setupImports() {
	c.gcloudPkg = c.NewImport(fmt.Sprintf("%s/%s", operatorPkgPrefix, "gcloud")
	c.protoPkg = c.NewImport(fmt.Sprintf("%s/%s", operatorPkgPrefix, "proto")
	c.contextPkg = c.NewImport("golang.org/x/net/context")
	c.grpcPkg = c.NewImport("google.golang.org/grpc")
}

func (c *cmd) generateService(
	file *google_protobuf.FileDescriptorProto,
	service *google_protobuf.ServiceDescriptorProto,
) {
	c.P("// service: ", fmt.Sprintf("%s", *service.Name))
	c.P("const commandName = ", *service.Package, "\"")
	c.P("")
	c.P("type serviceCommand struct {")
	c.In()
	c.P("client ", c.gcloudPkg.Use(), ".",
	c.P("func main() {")
	c.In()
	c.P("client := ", c.gcloudPkg.Use(), ".New", service.Name, "Client(conn)")

	for _, method := range service.Method {
		c.generateMethod(method)
	}

	c.Out()
	c.P("}")
}

func (c *cmd) generateMethod(method *google_protobuf.MethodDescriptorProto) {
	c.P("// response, err :=  ")
}

// gcloudClient := gcloud.NewGCloudServiceClient(conn)
// gcloudListInstancesResponse, err := gcloudClient.ListInstances(
// 	context.Background(),
// 	&gcloud.ListInstancesRequest{
// 		ProjectId: "dev-europe-west1",
// 	},
// )
// if err != nil {
// 	log.Fatal(err)
// }
// fmt.Print(gcloudListInstancesResponse.Output.PlainText)
