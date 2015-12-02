path = require "path"
grpc = require "grpc"
protobuf = require "protobufjs"

protodir = path.resolve(__dirname + "/../../proto")
proto = protobuf.loadProtoFile(root: protodir, file: "gcloud.proto")
gcloud = grpc.loadObject(proto.ns).gcloud
client = new gcloud.GCloudService("localhost:3000", grpc.Credentials.createInsecure())

module.exports = (robot) ->
  robot.respond /gcloud list/i, (msg) ->
    request = new gcloud.ListInstancesRequest()
    client.ListInstances(request) (err, response) ->
      for instance in response.instances
        msg.reply "#{response.id}"
