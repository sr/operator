package operator

import (
	"bytes"
	"flag"
	"fmt"
	"html/template"
	"os"
	"os/user"

	"github.com/kr/text"
)

const (
	programUsageTemplate = `Usage: {{.Program}} <service> <command> [arguments]

Use  "{{.Program}} help <service>" for help with a particular service.

Available services:
{{range $n, $s:= .Services}}
{{$n}}
{{WrappedIndent $s "  "}}
{{end}}`
	serviceUsageTemplate = `Usage: {{.Program}} {{.ServiceName}} [command]

{{Wrap .Synopsis}}

Available Commands:
{{range .Methods}}
{{.Name}}
{{WrappedIndent .Synopsis "  "}}
{{end}}`
)

const defaultAddress = "localhost:1234"

func (c Command) Run(args []string) (int, string) {
	if len(args) == 1 || isHelp(args[1]) {
		s, err := c.getProgramUsage()
		if err != nil {
			return 1, fmt.Sprintf("Unable to generate program usage: %v", err)
		}
		return 0, s
	}
	ok := false
	serviceName := args[1]
	var service ServiceCommand
	for _, s := range c.services {
		if s.Name == serviceName {
			ok = true
			service = s
		}
	}
	if !ok {
		return 1, fmt.Sprintf("No such service: %v\n", serviceName)
	}
	if len(args) == 2 || (len(args) == 3 && isHelp(args[2])) {
		s, err := c.getServiceUsage(service)
		if err != nil {
			return 1, fmt.Sprintf("Unable to generate service usage: %v", err)
		}
		return 0, s
	}
	ok = false
	methodName := args[2]
	var method MethodCommand
	for _, m := range service.Methods {
		if m.Name == methodName {
			ok = true
			method = m
		}
	}
	if !ok {
		return 1, fmt.Sprintf("No such method: %v\n", methodName)
	}
	addr, ok := os.LookupEnv("OPERATORD_ADDRESS")
	if !ok {
		addr = defaultAddress
	}
	output, err := method.Run(&CommandContext{
		Address: addr,
		Source:  getSource(),
		Flags:   flag.CommandLine,
		Args:    args[1:],
	})
	if err != nil {
		return 1, err.Error()
	}
	return 0, output
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
	t, err := template.New("t").Funcs(template.FuncMap{
		"Wrap": wrap, "WrappedIndent": wrappedIndent}).Parse(s)
	if err != nil {
		return "", err
	}
	var buf bytes.Buffer
	if err := t.Execute(&buf, data); err != nil {
		return "", err
	}
	return buf.String(), nil
}

func isHelp(arg string) bool {
	return arg == "-h" || arg == "--help"
}

func getSource() *Source {
	hostname, _ := os.Hostname()
	s := &Source{
		Type:     SourceType_COMMAND,
		Hostname: hostname,
	}
	u, err := user.Current()
	if err == nil {
		s.User = &User{
			Id:       u.Uid,
			Login:    u.Username,
			RealName: u.Name,
		}
	}
	return s
}

func wrap(s string) string {
	return text.Wrap(s, 80)
}

func wrappedIndent(s string, indentS string) string {
	return text.Indent(text.Wrap(s, 80-len(indentS)), indentS)
}
