package cmdgen

import "html/template"

var mainTemplate = template.Must(template.New("main-gen.go").Parse(
	`package main

import (
	"fmt"
	"os"
)

const usage = ` + "`" + `Usage: {{.BinaryName}} <service> <command>

Use  '{{.BinaryName}} help <service>' for help with a particular service.

Available services:
{{range .Services}}
  {{.Name}}{{range .Description}}
    {{.}}{{end}}
{{end}}` + "`" + `
func main() {
	if len(os.Args) == 1 || os.Args[1] == "-h" || os.Args[1] == "--help" ||
		os.Args[1] == "help" {
		fmt.Fprintf(os.Stderr, "%s\n", usage)
		os.Exit(2)
	}
}`))
