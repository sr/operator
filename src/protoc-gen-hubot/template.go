package hubot

import "text/template"

var scriptTemplate = template.Must(template.New("script.coffee").Parse(`
path = require "path"
grpc = require "grpc"
protobuf = require "protobufjs"

protodir = path.resolve(__dirname + "/../../src/proto")
proto = protobuf.loadProtoFile(root: protodir, file: "gcloud.proto")
gcloud = grpc.loadObject(proto.ns).gcloud
client = new gcloud.GCloudService("localhost:3000", grpc.Credentials.createInsecure())

module.exports = (robot) ->
{{range .Methods}}
  robot.respond /{{.ServiceName}} {{.MethodName}}/, (msg) ->
    request = new {{.ServiceName}}.{{.MethodRequest}}()
    client.{{.MethodName}}(request) (err, response) ->
	  msg.Send(response.Output.PlainText)
{{end}}
`))
