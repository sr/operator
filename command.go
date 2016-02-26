package operator

import (
	"bytes"
	"flag"
	"fmt"
	"html/template"
)

const (
	programUsageTemplate = `Usage: {{.Program}} <service> <command> [arguments]

Use  "{{.Program}} help <service>" for help with a particular service.

Available services:
{{range $n, $s:= .Services}}
{{$n}}
{{$s}}
{{end}}`
	serviceUsageTemplate = `Usage: {{.Program}} {{.ServiceName}} [command]

{{.Synopsis}}

Available Commands:
{{range .Methods}}
{{.Name}}
{{.Synopsis}}
{{end}}`
)

func (c Command) Run(args []string) (int, string) {
	if len(args) == 0 || isHelp(args[0]) {
		s, err := c.getProgramUsage()
		if err != nil {
			return 1, fmt.Sprintf("Unable to generate program usage: %v", err)
		}
		return 0, s
	}
	serviceName := args[0]
	var service ServiceCommand
	for _, s := range c.services {
		if s.Name == serviceName {
			service = s
		}
	}
	if &service == nil {
		return 1, fmt.Sprintf("No such service: %v\n", serviceName)
	}
	if len(args) >= 1 && isHelp(args[1]) {
		s, err := c.getServiceUsage(service)
		if err != nil {
			return 1, fmt.Sprintf("Unable to generate service usage: %v", err)
		}
		return 0, s
	}
	methodName := args[1]
	var method MethodCommand
	for _, m := range service.Methods {
		if m.Name == methodName {
			method = m
		}
	}
	if &method == nil {
		return 1, fmt.Sprintf("No such method: %v\n", methodName)
	}
	output, err := method.Run(args[2:], flag.CommandLine)
	if err != nil {
		return 1, err.Error()
	}
	return 0, output
}

func isHelp(arg string) bool {
	return arg == "-h" || arg == "--help"
}

func (c *Command) getProgramUsage() (string, error) {
	services := make(map[string]string, len(c.services))
	for _, s := range c.services {
		services[s.Name] = s.Synopsis
	}
	data := struct {
		Program  string
		Services map[string]string
	}{
		c.name,
		services,
	}
	return executeTemplate(programUsageTemplate, data)
}

func (c *Command) getServiceUsage(svc ServiceCommand) (string, error) {
	data := struct {
		Program     string
		ServiceName string
		Synopsis    string
		Methods     []MethodCommand
	}{
		c.name,
		svc.Name,
		svc.Synopsis,
		svc.Methods,
	}
	return executeTemplate(serviceUsageTemplate, data)
}

func executeTemplate(s string, data interface{}) (string, error) {
	t, err := template.New("t").Parse(s)
	if err != nil {
		return "", err
	}
	var buf bytes.Buffer
	if err := t.Execute(&buf, data); err != nil {
		return "", err
	}
	return buf.String(), nil
}
