
path = require "path"
grpc = require "grpc"
protobuf = require "protobufjs"

protodir = path.resolve(__dirname + "/../proto")
proto = protobuf.loadProtoFile(root: protodir, file: "papertrail.proto")
papertrail = grpc.loadObject(proto.ns).papertrail
address = process.env.OPERATORD_ADDRESS
if !address
  host = process.env.OPERATORD_PORT_3000_TCP_ADDR
  port = process.env.OPERATORD_PORT_3000_TCP_PORT
  address = "#{host}:#{port}"

client = new papertrail.PapertrailService(address, grpc.Credentials.createInsecure())

module.exports = (robot) ->

	robot.respond /papertrail search query=(\w+)/, (msg) ->
		client.search {query: msg.match[1],}, (err, response) ->
			if err
				msg.send("papertrail error: #{err.message}")
			else
				msg.send(response.Output.PlainText)
