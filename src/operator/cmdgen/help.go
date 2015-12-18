package cmdgen

import "html/template"

var mainTemplate = template.Must(template.New("main-gen.go").Parse(
	`Usage: {{.BinaryName}} <service> <command>

Use ` + "`" + `{{.BinaryName}} help <service>"` + ` for help with a particular service.

Available services:
{{range .Services}}
  {{.Name}}{{range .Description}}
    {{.}}{{end}}

{{end}}`))
