
path = require "path"
grpc = require "grpc"
protobuf = require "protobufjs"

protodir = path.resolve(__dirname + "/../proto")
proto = protobuf.loadProtoFile(root: protodir, file: "gcloud.proto")
gcloud = grpc.loadObject(proto.ns).gcloud
host = process.env.OPERATORD_PORT_3000_TCP_ADDR
port = process.env.OPERATORD_PORT_3000_TCP_PORT
address = "#{host}:#{port}"
client = new gcloud.GCloudService(address, grpc.Credentials.createInsecure())

module.exports = (robot) ->

	robot.respond /gcloud list-instances project_id=(\w+)/, (msg) ->
		client.listInstances {project_id: msg.match[1],}, (err, response) ->
			if err
				msg.send("gcloud error: #{err.message}")
			else
				msg.send(response.Output.PlainText)

