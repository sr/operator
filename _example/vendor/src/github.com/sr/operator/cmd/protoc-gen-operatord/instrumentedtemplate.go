package main

import "github.com/sr/operator/generator"

var instrumentedTemplate = generator.NewTemplate("instrumented-gen.go",
	`// Code generated by protoc-gen-operatord
package main

import (
	"github.com/sr/grpcinstrument"
	"golang.org/x/net/context"
	"time"

{{range .Services}}
	{{.PackageName}} "{{.ImportPath}}"
{{end}}
)

{{range .Services}}
type instrumented{{.PackageName}}_{{.FullName}} struct {
	instrumentator grpcinstrument.Instrumentator
	server         {{.FullName}}
}
{{end}}
{{range .Services}}
func newInstrumented{{.PackageName}}_{{.FullName}}(
	instrumentator grpcinstrument.Instrumentator,
	server {{.FullName}},
) *instrumented{{.PackageName}}_{{.FullName}} {
	return &Instrumented{{.PackageName}}_{{.FullName}}{
		instrumentator,
		server,
	}
}
{{range .Methods}}
// {{.Name}} instruments the {{.ServerInterface}}.{{.Name}} method.
func (a *Instrumented{{.ServerInterface}}) {{.Name}}(
	ctx context.Context,
	request *{{.InputType}},
) (response *{{.OutputType}}, err error) {
	defer func(start time.Time) {
		grpcinstrument.Instrument(
			a.instrumentator,
			"{{.Service}}",
			"{{.Name}}",
			"{{.InputType}}",
			"{{.OutputType}}",
			err,
			start,
		)
	}(time.Now())
	return a.server.{{.Name}}(ctx, request)
}
{{end}}{{end}}`)