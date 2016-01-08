package gencmd

import "github.com/sr/operator/src/generator"

var (
	mainUsageTemplate = generator.NewTemplate("main",
		`Usage: {{.Options.BinaryName}} <service> <command>

Use  "{{.Options.BinaryName}} help <service>" for help with a particular service.

Available services:
{{range .Services}}
{{.Name}}
{{wrappedIndent .Description "  "}}
{{end}}`)

	serviceUsageTemplate = generator.NewTemplate("service",
		`Usage: {{.BinaryName}} {{.Service.Name}} [command]

{{wrap .Service.Description}}

Available Commands:
{{range .Service.Methods}}
  {{dasherize .Name}}{{.Description}}
{{end}}`)
)

var mainTemplate = generator.NewTemplate("main-gen.go",
	`package main

import (
	"golang.org/x/net/context"
	"google.golang.org/grpc"
	"flag"
	"fmt"
	"os"
	"go.pedge.io/env"
	{{- range .Services}}
	{{.PackageName}} "{{.ImportPath}}"
	{{- end}}
)

const (
	usage = `+"`"+`{{.MainUsage}}`+"`"+`

{{- range .Services}}
	usageService{{camelCase .Name}} = `+"`"+`{{index $.ServiceUsage .Name}}`+"`"+`
{{- end -}}
)

type mainEnv struct {
	Address string `+"`"+`env:"OPERATORD_ADDRESS,default=localhost:3000"`+"`"+`
}

type client struct {
	client *grpc.ClientConn
}

func dial(address string) (*client, error) {
	conn, err := grpc.Dial(address, grpc.WithInsecure())
	if err != nil {
		return nil, err
	}
	return &client{conn}, nil
}

func (c *client) close() {
	c.client.Close()
}

func isHelp(arg string) bool {
	return arg == "-h" || arg == "--help" || arg == "help"
}

func showUsage(s string) {
	fmt.Fprintf(os.Stderr, "%s\n", s)
	os.Exit(2)
}

func fatal(message string) {
	fmt.Fprintf(os.Stderr, "{{.Options.BinaryName}}: %s\n", message)
	os.Exit(1)
}

{{- range .Services}}
{{- $serviceName := .Name }}
{{- $serviceFullName := .FullName }}
{{- range .Methods}}
func (c *client) do{{ camelCase $serviceName }}{{.Name}}() (string, error) {
	flags := flag.NewFlagSet("{{dasherize .Name}}", flag.ExitOnError)
	{{- range .Arguments}}
	{{.Name}} := flags.String("{{dasherize .Name}}", "", "")
	{{- end}}
	flags.Parse(os.Args[2:])
	client := {{$serviceName}}.New{{$serviceFullName}}Client(c.client)
	response, err := client.{{.Name}}(
		context.Background(),
		&{{$serviceName}}.{{.Input}}{
			{{- range .Arguments}}
			{{camelCase .Name}}: *{{.Name}},
			{{- end}}
		},
	)
	if err != nil {
		return "", err
	}
	return response.Output.PlainText, nil
}
{{end -}}
{{end}}

func main() {
	mainEnv := &mainEnv{}
	if err := env.Populate(mainEnv); err != nil {
		fatal(err.Error())
	}
	if len(os.Args) == 1 || isHelp(os.Args[1]) {
		showUsage(usage)
	}
	if len(os.Args) >= 2 {
		service := os.Args[1]
		switch service {
		{{- range .Services}}
		{{- $serviceName := .Name }}
		case "{{.Name}}":
			if len(os.Args) == 2 || isHelp(os.Args[2]) {
				showUsage(usageService{{camelCase $serviceName}})
			} else {
				command := os.Args[2]
				switch command {
				{{- range .Methods}}
				case "{{dasherize .Name}}":
					client, err := dial(mainEnv.Address)
					if err != nil {
						fatal(err.Error())
					}
					defer client.close()
					output, err := client.do{{camelCase $serviceName}}{{.Name}}()
					if err != nil {
						fatal(err.Error())
					}
					fmt.Fprintf(os.Stdout, "%s\n", output)
					os.Exit(0)
				{{- end}}
				default:
					fatal(fmt.Sprintf("no such command: %s", command))
				}
			}
{{- end}}
		default:
			fatal(fmt.Sprintf("no such service: %s", service))
		}
	}
}`)
