package main

import "github.com/sr/operator/generator"

var builderTemplate = generator.NewTemplate("builder-gen.go",
	`// Code generated by protoc-gen-operatord
package main

import (
	"errors"
	"flag"
	"os"
	"strings"

	"google.golang.org/grpc"

{{range .Services}}
	{{.PackageName}} "{{.ImportPath}}"
{{- end}}
)

func buildOperatorServer(
	server *grpc.Server,
	flags *flag.FlagSet,
) (map[string]error, error) {
{{- range .Services}}
	{{.PackageName}}Config := &{{.PackageName}}.{{.FullName}}Config{}
{{- end}}
{{- range .Services}}
	{{- $serviceName := .PackageName }}
	{{- range .Config}}
	flags.StringVar(&{{$serviceName}}Config.{{camelCase .Name}}, "{{$serviceName}}-{{.Name}}", "", "")
	{{- end}}
{{- end}}
	services := make(map[string]error)
	if err := flags.Parse(os.Args[1:]); err != nil {
		return services, err
	}
	errs := make(map[string][]string)
{{- range .Services}}
	{{- $serviceName := .PackageName }}
	{{- range .Config}}
	if {{$serviceName}}Config.{{camelCase .Name}} == "" {
		errs["{{$serviceName}}"] = append(errs["{{$serviceName}}"], "{{.Name}}")
	}
	{{- end }}
{{- end }}
{{- range .Services}}
	if len(errs["{{.Name}}"]) != 0 {
		services["{{.Name}}"] = errors.New("required flag(s) missing: "+strings.Join(errs["{{.Name}}"], ", "))
	} else {
		{{.PackageName}}Server, err := {{.PackageName}}.NewAPIServer({{.PackageName}}Config)
		if err != nil {
			services["{{.Name}}"] = err
		} else {
			{{.PackageName}}.Register{{camelCase .FullName}}Server(server, {{.PackageName}}Server)
			services["{{.Name}}"] = nil
		}
	}
{{- end}}
	return services, nil
}`)