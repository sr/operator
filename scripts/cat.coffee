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
#    echo "hello everyone" | nc -u -w1 localhost 7890
#    
# Author:
#   simon

dgram  = require "dgram"
server = dgram.createSocket "udp4"

module.exports = (robot) ->
  server.on 'message', (message, rinfo) ->
    msg  = message.toString().trim()
    user = { room: process.env.HUBOT_IRC_ROOMS }
    robot.send user, msg
  server.bind(parseInt(process.env.HUBOT_CAT_PORT))