package cmd

import "text/template"

var commandTemplate = template.Must(template.New("main-gen.go").Parse(`
package main

import (
	context "golang.org/x/net/context"
	flag "flag"
	math "math"
	fmt "fmt"
	grpc "google.golang.org/grpc"
	operator "github.com/sr/operator/src/operator"
	os "os"
	service "github.com/sr/operator/src/services/papertrail"
	proto "github.com/gogo/protobuf/proto"
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
	flags := flag.NewFlagSet("{{.SneakCasedName}}", flag.ExitOnError)
{{range .Arguments}}
	{{.Name}} := flags.String("{{.DasherizedName}}", "", "")
{{end}}
	flags.Parse(os.Args[2:])
	response, err := s.client.Search(
		context.Background(),
		&papertrail.SearchRequest{
		{{range .Arguments}}
			{{.Name}}: *{{.LowerCaseName}},
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
	case "{{.SneakCasedName}}":
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
	client := service.{{.ServiceClient}}(conn)
	service := newServiceCommand(client)
	method := os.Args[1]
	output, err := service.handle(method)
	if err != nil {
		fmt.Fprintf(os.Stderr, "%v\n", err)
		os.Exit(1)
	}
	fmt.Fprintln(os.Stdout, output.PlainText)
}
`))
