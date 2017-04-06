package operator

import (
	"bytes"
	"flag"
	"fmt"
	"html/template"
	"io/ioutil"
	"os"
	"os/user"
	"time"

	"github.com/kr/text"
	"google.golang.org/grpc"
)

const (
	operatorAddr         = "OPERATOR_ADDR"
	programUsageTemplate = `Usage: {{.Program}} <service> <command> [options]

Use  "{{.Program}} <service> --help" for help with a particular service.

Available services:
{{range $n, $s:= .Services}}
{{$n}}
{{WrappedIndent $s "  "}}
{{end}}`
	serviceUsageTemplate = `Usage: {{.Program}} {{.ServiceName}} [command] [options]

{{Wrap .Synopsis}}

General Options:

  -operator-addr string
	The address of the Operator server. Overrides the {{.AddrEnvVar}} environment
	variable if set. (default "{{.DefaultAddr}}")

Available Commands:
{{range .Methods}}
{{.Name}}
{{WrappedIndent .Synopsis "  "}}
{{ if .Usage }}
{{.Usage}}
{{- end }}
{{- end}}`
)

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
		return 1, fmt.Sprintf("No such service: %v", serviceName)
	}
	serviceUsage, err := c.getServiceUsage(service)
	if err != nil {
		return 1, fmt.Sprintf("Unable to generate service usage: %v", err)
	}
	if len(args) == 2 || (len(args) == 3 && isHelp(args[2])) {
		return 0, serviceUsage
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
		return 1, fmt.Sprintf("Service \"%s\" has no method \"%v\"", serviceName, methodName)
	}
	ctx := &CommandContext{
		Args:    args[3:],
		Flags:   flag.NewFlagSet(c.name, flag.ContinueOnError),
		Request: &Request{Source: getSource()},
	}
	ctx.Flags.Usage = func() {}
	ctx.Flags.SetOutput(ioutil.Discard)
	ctx.Flags.StringVar(&ctx.Address, "operator-addr", "", "")
	output, err := method.Run(ctx)
	if err == flag.ErrHelp {
		return 0, serviceUsage
	}
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
	type cmd struct {
		MethodCommand
		Usage string
	}
	commands := make([]cmd, len(svc.Methods))
	for i, m := range svc.Methods {
		commands[i] = cmd{
			MethodCommand: m,
			Usage:         getMethodUsage(m),
		}
	}
	data := struct {
		AddrEnvVar  string
		DefaultAddr string
		Methods     []cmd
		Program     string
		ServiceName string
		Synopsis    string
	}{
		operatorAddr,
		DefaultAddress,
		commands,
		c.name,
		svc.Name,
		svc.Synopsis,
	}
	return executeTemplate(serviceUsageTemplate, data)
}

const dialTimeout = 5 * time.Second

func (c *CommandContext) GetConn() (*grpc.ClientConn, error) {
	if v, ok := os.LookupEnv(operatorAddr); ok && c.Address == "" {
		c.Address = v
	}
	if c.Address == "" {
		c.Address = DefaultAddress
	}
	return grpc.Dial(
		c.Address,
		grpc.WithBlock(),
		grpc.WithTimeout(dialTimeout),
		grpc.WithInsecure(),
	)
}

func getMethodUsage(m MethodCommand) string {
	s := ""
	for _, f := range m.Flags {
		s += fmt.Sprintf("  -%s", f.Name)
		name, usage := flag.UnquoteUsage(f)
		if len(name) > 0 {
			s += " " + name
		}
		if len(s) <= 4 {
			s += "\t"
		} else {
			s += "\n    \t"
		}
		s += usage
		s += "\n"
	}
	return s
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
	return arg == "-h" || arg == "-help" || arg == "--help"
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
