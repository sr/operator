package cmdgen

import "text/template"

var mainTemplate = template.Must(template.New("main-gen.go").Parse(
	`package main

import (
	"golang.org/x/net/context"
	"google.golang.org/grpc"
	"flag"
	"fmt"
	"os"
	"go.pedge.io/env"
	buildkite "github.com/sr/operator/src/services/buildkite"
)

const usage = ` + "`" + `Usage: {{.BinaryName}} <service> <command>

Use  '{{.BinaryName}} help <service>' for help with a particular service.

Available services:
{{range .Services}}
  {{.Name}}{{range .Description}}
    {{.}}{{end}}
{{end}}` + "`" + `

type mainEnv struct {
	Address string ` + "`" + `env:"OPERATORD_ADDRESS,default=localhost:3000"` + "`" + `
}

func showUsage(s string) {
	fmt.Fprintf(os.Stderr, "%s\n", s)
	os.Exit(2)
}

func fatal(message string) {
	fmt.Fprintf(os.Stderr, "{{.BinaryName}}: %s\n", message)
	os.Exit(1)
}

func main() {
	mainEnv := &mainEnv{}
	if err := env.Populate(mainEnv); err != nil {
		fatal(err.Error())
	}
	if len(os.Args) == 1 || os.Args[1] == "-h" || os.Args[1] == "--help" ||
		os.Args[1] == "help" {
		showUsage(usage)
	}
	if len(os.Args) >= 2 {
		service := os.Args[1]
		switch service {
		{{range .Services}}
		case "{{.Name}}":
			if (len(os.Args) == 2 || (os.Args[2] == "-h" ||
				os.Args[2] == "--help" || os.Args[2] == "help")) {
				showUsage(` + "`" + `Usage: {{.BinaryName}} {{.Name}} [command]
{{range .Description}}
{{.}}{{end}}
Available Commands:{{range .Methods}}
  {{.NameDasherized}} {{.Description}}{{end}}` + "`" + `)
			} else {
				command := os.Args[2]
				switch command {
				{{range .Methods}}
				case "{{.NameDasherized}}":
					flags := flag.NewFlagSet("{{.NameDasherized}}", flag.ExitOnError)
					{{range .Arguments}}
					{{.NameSnakeCase}} := flags.String("{{.NameDasherized}}", "", "")
					{{end}}
					flags.Parse(os.Args[2:])
					conn, err := grpc.Dial(mainEnv.Address, grpc.WithInsecure())
					if err != nil {
						fatal(err.Error())
					}
					defer conn.Close()
					client := {{.ServicePkg}}.New{{.ServiceClient}}(conn)
					response, err := client.{{.Name}}(
						context.Background(),
						&{{.ServicePkg}}.{{.Input}}{
						{{range .Arguments}}
							{{.Name}}: *{{.NameSnakeCase}},
						{{end}}
						},
					)
					if err != nil {
						fatal(err.Error())
					}
					fmt.Fprintf(os.Stdout, "%s\n", response.Output.PlainText)
					os.Exit(0)
				{{end}}
				default:
					fatal(fmt.Sprintf("no such command: %s", command))
				}
			}

{{end}}
		default:
			fatal(fmt.Sprintf("no such service: %s", service))
		}
	}
}`))
