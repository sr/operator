package main

import "generator"

var template = generator.NewTemplate("script.coffee",
	`# Description:
#  {{oneLine .Description}}
#
# Commands:
{{- range .Methods}}
#   hubot {{$.Name}} {{dasherize .Name}} - {{oneLine .Description}}
{{- end}}
#
# Configuration:
#   OPERATORD_ADDRESS
path = require "path"
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

client = new {{.PackageName}}.{{.FullName}}(address, grpc.Credentials.createInsecure())

module.exports = (robot) ->
{{$service := .Name}}
{{- range .Methods}}
  robot.respond /{{$service}} {{dasherize .Name}}{{index $.Args .Name}}/, (msg) ->
    client.{{lowerCase .Name}} {{index $.Input .Name}}, (err, response) ->
      if err
        msg.send("`+"```"+`\n{{.Name}} error: #{err.message}\n`+"```"+`")
      else
        msg.send("`+"```"+`\n#{response.output.PlainText}\n`+"```"+`")
{{end}}
`)
