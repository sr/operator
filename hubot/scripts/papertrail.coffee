
path = require "path"
grpc = require "grpc"
protobuf = require "protobufjs"

protodir = path.resolve(__dirname + "/../../src/proto")
proto = protobuf.loadProtoFile(root: protodir, file: "PapertrailService.proto")
papertrail = grpc.loadObject(proto.ns).papertrail
client = new papertrail.PapertrailService("localhost:3000", grpc.Credentials.createInsecure())

module.exports = (robot) ->

  robot.respond /^papertrail search query=(\w+)$/, (msg) ->
    request = new client.SearchRequest()
    client.Search(request) (err, response) ->
	  msg.send(response.Output.PlainText)
