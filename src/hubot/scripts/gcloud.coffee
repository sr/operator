path = require "path"
grpc = require "grpc"
protobuf = require "protobufjs"

protodir = path.resolve(__dirname + "/../proto")
proto = protobuf.loadProtoFile(root: protodir, file: "gcloud.proto")
gcloud = grpc.loadObject(proto.ns).gcloud
address = process.env.OPERATORD_ADDRESS
if !address
  host = process.env.OPERATORD_PORT_3000_TCP_ADDR
  port = process.env.OPERATORD_PORT_3000_TCP_PORT
  address = "#{host}:#{port}"

client = new gcloud.gcloud(address, grpc.Credentials.createInsecure())

module.exports = (robot) ->

	robot.respond /gcloud CreateContainerClusterTODO(sr)/, (msg) ->
		client.CreateContainerCluster {a: 1, b: 2}, (err, response) ->
			if err
				msg.send("```\nCreateContainerCluster error: #{err.message}\n```")
			else
				msg.send("```\n#{response.output.PlainText}\n```")

	robot.respond /gcloud ListInstancesTODO(sr)/, (msg) ->
		client.ListInstances {a: 1, b: 2}, (err, response) ->
			if err
				msg.send("```\nListInstances error: #{err.message}\n```")
			else
				msg.send("```\n#{response.output.PlainText}\n```")
