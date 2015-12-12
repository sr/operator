package cmd

import "text/template"

type serviceCommandDescriptor struct {
	ServiceImportPath string
	CommandName       string
	ServiceClient     string
	Methods           []*methodDescriptor
}

type methodDescriptor struct {
	Name           string
	SnakeCasedName string
	DasherizedName string
	Input          string
	Arguments      []*argumentDescriptor
}

type argumentDescriptor struct {
	SnakeCaseName  string
	CamelCaseName  string
	DasherizedName string
}

var commandTemplate = template.Must(template.New("main-gen.go").Parse(
	`package main

import (
	context "golang.org/x/net/context"
	flag "flag"
	fmt "fmt"
	grpc "google.golang.org/grpc"
	operator "github.com/sr/operator/src/operator"
	os "os"
	service "{{.ServiceImportPath}}"
)

const commandName = "{{.CommandName}}"

type serviceCommand struct {
	client service.{{.ServiceClient}}
}

func newServiceCommand(client service.{{.ServiceClient}}) *serviceCommand {
	return &serviceCommand{client}
}
{{range .Methods}}
func (s *serviceCommand) {{.Name}}() (*operator.Output, error) {
	flags := flag.NewFlagSet("{{.DasherizedName}}", flag.ExitOnError)
{{range .Arguments}}
	{{.SnakeCaseName}} := flags.String("{{.DasherizedName}}", "", "")
{{end}}
	flags.Parse(os.Args[2:])
	response, err := s.client.{{.Name}}(
		context.Background(),
		&service.{{.Input}}{
		{{range .Arguments}}
			{{.CamelCaseName}}: *{{.SnakeCaseName}},
		{{end}}
		},
	)
	if err != nil {
		return nil, err
	}
	return response.Output, nil
}
{{end}}
func (s *serviceCommand) handle(method string) (*operator.Output, error) {
	switch method {
{{range .Methods}}
	case "{{.SnakeCasedName}}":
		return s.{{.Name}}()
{{end}}
	default:
		return nil, fmt.Errorf("unspported method: %s", method)
	}
}

func main() {
	conn, err := grpc.Dial(":3000", grpc.WithInsecure())
	if err != nil {
		panic(err)
	}
	defer conn.Close()
	if len(os.Args) < 2 {
		fmt.Fprintf(os.Stderr, "Usage: %s <method> \n", commandName)
		os.Exit(1)
	}
	client := service.New{{.ServiceClient}}(conn)
	service := newServiceCommand(client)
	method := os.Args[1]
	output, err := service.handle(method)
	if err != nil {
		fmt.Fprintf(os.Stderr, "%v\n", err)
		os.Exit(1)
	}
	fmt.Fprintln(os.Stdout, output.PlainText)
}`))
