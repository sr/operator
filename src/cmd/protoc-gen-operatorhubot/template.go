package main

import "github.com/sr/operator/src/generator"

var template = generator.NewTemplate("script.coffee",
	`path = require "path"
grpc = require "grpc"
protobuf = require "protobufjs"

protodir = path.resolve(__dirname + "/../proto")
proto = protobuf.loadProtoFile(root: protodir, file: "{{.PackageName}}.proto")
{{.Name}} = grpc.loadObject(proto.ns).{{.Name}}
address = process.env.OPERATORD_ADDRESS
if !address
  host = process.env.OPERATORD_PORT_3000_TCP_ADDR
  port = process.env.OPERATORD_PORT_3000_TCP_PORT
  address = "#{host}:#{port}"

client = new {{.PackageName}}.{{.Name}}(address, grpc.Credentials.createInsecure())

module.exports = (robot) ->
{{$service := .Name}}
{{- range .Methods}}
	robot.respond /{{$service}} {{.Name}}TODO(sr)/, (msg) ->
		client.{{.Name}} {a: 1, b: 2}, (err, response) ->
			if err
				msg.send("`+"```"+`\n{{.Name}} error: #{err.message}\n`+"```"+`")
			else
				msg.send("`+"```"+`\n#{response.output.PlainText}\n`+"```"+`")
{{end}}
`)
