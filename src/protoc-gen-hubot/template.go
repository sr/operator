package hubot

import "text/template"

type templateService struct {
	Debug   string
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

protodir = path.resolve(__dirname + "/../../src/proto")
proto = protobuf.loadProtoFile(root: protodir, file: "{{.Service}}.proto")
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
