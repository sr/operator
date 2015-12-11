package hubot

import "text/template"

type templateService struct {
	Package string
	Service string
	Methods []*templateMethod
}

type templateMethod struct {
	Service   string
	Name      string
	NameLower string
	Input     string
	Arguments string
}

var scriptTemplate = template.Must(template.New("script.coffee").Parse(`
path = require "path"
grpc = require "grpc"
protobuf = require "protobufjs"

protodir = path.resolve(__dirname + "/../proto")
proto = protobuf.loadProtoFile(root: protodir, file: "{{.Package}}.proto")
{{.Package}} = grpc.loadObject(proto.ns).{{.Package}}
client = new {{.Package}}.{{.Service}}("localhost:3000", grpc.Credentials.createInsecure())

module.exports = (robot) ->
{{range .Methods}}
  robot.respond /^{{.Service}} {{.NameLower}}{{.Arguments}}$/, (msg) ->
    request = new client.{{.Input}}()
    client.{{.Name}}(request) (err, response) ->
	  msg.send(response.Output.PlainText)
{{end}}
`))
