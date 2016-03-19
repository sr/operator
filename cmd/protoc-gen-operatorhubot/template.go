package main

import "github.com/sr/operator/generator"

var template = generator.NewTemplate("script.js",
	`// Description:
//  {{oneLine .Description}}
//
// Commands:
{{- range .Methods}}
//   hubot {{$.Name}} {{dasherize .Name}} {{index $.Args .Name}} - {{oneLine .Description}}
{{- end}}
//
// Configuration:
//   OPERATORD_ADDRESS
var path = require("path"),
	grpc = require("grpc"),
	protobuf = require("protobufjs");

var protodir = path.resolve(__dirname + "/../proto"),
	proto = protobuf.loadProtoFile({root: protodir, file: "{{.PackageName}}.proto"})
	operator = proto.build("operator"),
	{{.Name}} = grpc.loadObject(proto.ns).{{.Name}};

var address = process.env.OPERATORD_ADDRESS,
	client = new {{.PackageName}}.{{.FullName}}(address, grpc.Credentials.createInsecure());

module.exports = function(robot) {
{{$service := .Name}}
{{- range .Methods}}
	robot.respond(/{{$service}} {{dasherize .Name}}(.*)/, function(msg) {
		var input = {},
			ref = msg.match[1].split(" ");
		input.source = {
			type: operator.SourceType.HUBOT,
			room: {name: msg.message.room},
			user: {
				id: msg.message.user.id,
				login: msg.message.user.name,
			}
		}
		for (i = 0, len = ref.length; i < len; i++) {
			var arg = ref[i],
				parts = arg.split("=");
			if (parts.length === 2 && parts[0] !== "" && parts[1] !== "") {
				input[parts[0]] = parts[1];
			}
		}
		return client.{{lowerCase .Name}}(input, function(err, response) {
			if (err) {
				return msg.send("`+"```"+`\n{{.Name}} error: " + err.message + "\n`+"```"+`")
			} else {
				return msg.send("`+"```"+`\n" + response.output.PlainText + "\n`+"```"+`")
			}
		});
	});
{{end}}
}
`)
