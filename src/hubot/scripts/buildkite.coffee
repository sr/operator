path = require "path"
grpc = require "grpc"
protobuf = require "protobufjs"

protodir = path.resolve(__dirname + "/../proto")
proto = protobuf.loadProtoFile(root: protodir, file: "buildkite.proto")
buildkite = grpc.loadObject(proto.ns).buildkite
address = process.env.OPERATORD_ADDRESS
if !address
  host = process.env.OPERATORD_PORT_3000_TCP_ADDR
  port = process.env.OPERATORD_PORT_3000_TCP_PORT
  address = "#{host}:#{port}"

client = new buildkite.buildkite(address, grpc.Credentials.createInsecure())

module.exports = (robot) ->

	robot.respond /buildkite StatusTODO(sr)/, (msg) ->
		client.Status {a: 1, b: 2}, (err, response) ->
			if err
				msg.send("```\nStatus error: #{err.message}\n```")
			else
				msg.send("```\n#{response.output.PlainText}\n```")

	robot.respond /buildkite ListBuildsTODO(sr)/, (msg) ->
		client.ListBuilds {a: 1, b: 2}, (err, response) ->
			if err
				msg.send("```\nListBuilds error: #{err.message}\n```")
			else
				msg.send("```\n#{response.output.PlainText}\n```")
