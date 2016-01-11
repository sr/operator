# Description:
#  Undocumented.
#
# Commands:
#   hubot controller create-cluster - Undocumented.
#
# Configuration:
#   OPERATORD_ADDRESS
path = require "path"
grpc = require "grpc"
protobuf = require "protobufjs"

protodir = path.resolve(__dirname + "/../proto")
proto = protobuf.loadProtoFile(root: protodir, file: "controller.proto")
controller = grpc.loadObject(proto.ns).controller
address = process.env.OPERATORD_ADDRESS
if !address
  host = process.env.OPERATORD_PORT_3000_TCP_ADDR
  port = process.env.OPERATORD_PORT_3000_TCP_PORT
  address = "#{host}:#{port}"

client = new controller.Controller(address, grpc.Credentials.createInsecure())

module.exports = (robot) ->

  robot.respond /controller create-cluster/, (msg) ->
    client.createCluster {}, (err, response) ->
      if err
        msg.send("```\nCreateCluster error: #{err.message}\n```")
      else
        msg.send("```\n#{response.output.PlainText}\n```")

