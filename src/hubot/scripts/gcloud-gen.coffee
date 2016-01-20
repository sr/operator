# Description:
#  Undocumented.
#
# Commands:
#   hubot gcloud create-container-cluster - Undocumented.
#   hubot gcloud list-instances - Undocumented.
#
# Configuration:
#   OPERATORD_ADDRESS
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

client = new gcloud.GcloudService(address, grpc.Credentials.createInsecure())

module.exports = (robot) ->

  robot.respond /gcloud create-container-cluster(.*)/, (msg) ->
    input = {}
    for arg in msg.match[1].split(" ")
      parts = arg.split("=")
      if parts.length == 2 && parts[0] != "" && parts[1] != ""
        input[parts[0]] = parts[1]
    client.createContainerCluster input, (err, response) ->
      if err
        msg.send("```\nCreateContainerCluster error: #{err.message}\n```")
      else
        msg.send("```\n#{response.output.PlainText}\n```")

  robot.respond /gcloud list-instances(.*)/, (msg) ->
    input = {}
    for arg in msg.match[1].split(" ")
      parts = arg.split("=")
      if parts.length == 2 && parts[0] != "" && parts[1] != ""
        input[parts[0]] = parts[1]
    client.listInstances input, (err, response) ->
      if err
        msg.send("```\nListInstances error: #{err.message}\n```")
      else
        msg.send("```\n#{response.output.PlainText}\n```")

