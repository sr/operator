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
util = require "../lib/util"

module.exports = (robot) ->
  try
    server = net.createServer((c) ->
      c.on "data", (data) ->
        msg  = data.toString().trim()
        user = { room: process.env.HUBOT_IRC_ROOMS }

        if msg is "command:getNicks"
          channel = robot.adapter.bot.chans[process.env.HUBOT_IRC_ROOMS]
          users = Object.keys channel.users
          c.write users.toString().replace(/,/g, " ")
          c.pipe c
        else
          recordRelease msg
          #recordFires msg

          try
            robot.send user, msg
          catch e
            console.log e

        c.end()
    )

    server.listen parseInt(process.env.HUBOT_CAT_PORT), ->
      console.log "cat listening"
  catch e
    console.log e
    console.log "CAT FAILED!"

# Record the relase infos
recordRelease = (msg) ->
  if process.env.RELEASE_TRACKING_ENABLED == 'true'

    eb just began syncing r58399 to PROD on

    match = msg.match(/^(\w\w)\sjust\began\ssyncing\sr(\d+)\sto\sPROD\son\semail-d1\.pardot\.com/i)
    conn = util.getReleaseDBConn()

    if match isnt null
      conn.query 'INSERT INTO sync (releaser, revision, date) VALUES(?, ?, NOW())', [match[1], match[2]], (err,r,f) ->
          if err
            conn.end()
            return console.log err 

      conn.end()

# Record production fires
#recordFires = (msg) ->
#  if process.env.FIRE_RECORDING_ENABLED == 'true'
#    score = 0

    # Solr out of date
#    match = msg.match(/^Solr\sout\sof\sdate\son\sshard\s\d*\.*/i)
#    if match isnt null
#      score += 2

#    match = msg.match(/^Solr\d:\sCaught\sRestCurlException/i)
#    if match isnt null
#      score += 2

#    match = msg.match((/^Error\s\'Duplicate\sentry/i)
#    if match isnt null
#      score += 10

#    match = msg.match((/^Replication\sfailed\son\sdb-/i)
#    if match isnt null
#      score += 10













