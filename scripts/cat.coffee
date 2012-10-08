# Description:
#   Send messages to channels via hubot
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_CAT_PORT
#
# Commands:
#   None
#
# Notes:
#    echo "hello everyone" | nc -w1 127.0.0.1 7890
#    
# Author:
#   Berg

net = require "net"

module.exports = (robot) ->
  try
    server = net.createServer((c) ->
      c.on "data", (data) ->
        msg  = data.toString().trim()
        user = { room: process.env.HUBOT_IRC_ROOMS }
        robot.send user, msg
    )

    server.listen parseInt(process.env.HUBOT_CAT_PORT), ->
      console.log "cat listening"
  catch e
    console.log e
    console.log "CAT FAILED!"
  