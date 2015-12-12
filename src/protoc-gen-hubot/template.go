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
	NameSnake string
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
address = process.env.OPERATORD_ADDRESS
if !address
  host = process.env.OPERATORD_PORT_3000_TCP_ADDR
  port = process.env.OPERATORD_PORT_3000_TCP_PORT
  address = "#{host}:#{port}"

client = new {{.Package}}.{{.Service}}(address, grpc.Credentials.createInsecure())

module.exports = (robot) ->
{{range .Methods}}
	robot.respond /{{.Service}} {{.NameSnake}}{{.Arguments}}/, (msg) ->
		client.{{.Name}} {{.Input}}, (err, response) ->
			if err
				msg.send("` + "```" + `\n{{.Service}} error: #{err.message}\n` + "```" + `")
			else
				msg.send("` + "```" + `\n#{response.output.PlainText}\n` + "```" + `")
{{end}}
`))
