package logger

import "text/template"

type fileDescriptor struct {
	Package         string
	ServerInterface string
	Methods         []*methodDescriptor
}

type methodDescriptor struct {
	Name     string
	Request  string
	Response string
}

var loggerTemplate = template.Must(template.New("log_api_server.go").Parse(`
package {{.Package}}

import (
	"time"

	"go.pedge.io/proto/rpclog"
	"golang.org/x/net/context"
)

type logAPIServer struct {
	protorpclog.Logger
	delegate {{.ServerInterface}}
}

func NewLogAPIServer(delegate {{.ServerInterface}}) *logAPIServer {
	return &logAPIServer{protorpclog.NewLogger("{{.Package}}"), delegate}
}

{{range .Methods}}
func (a *logAPIServer) {{.Name}}(ctx context.Context, request *{{.Request}}) (response *{{.Response}}, err error) {
	defer func(start time.Time) { a.Log(request, nil, err, time.Since(start)) }(time.Now())
	return a.delegate.{{.Name}}(ctx, request)
}
{{end}}`))
