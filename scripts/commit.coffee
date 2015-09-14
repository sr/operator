# Description:
#   Retrieves the commit url from Github
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot commit <sha> - responds with the commit url for the Pardot repo
#   hubot commit <project> <sha> - responds with the commit url for any repo
#   hubot diff <sha> - responds with the compare url for the Pardot repo
#   hubot diff <sha1> <sha2> - responds with the compare url for the Pardot repo
#
# Author:
#   parkermcgee

module.exports = (robot) ->
  robot.respond /commit\s+([a-f0-9]+)$/i, (msg) ->
    sha = msg.match[1]
    msg.send "https://git.dev.pardot.com/Pardot/pardot/commit/" + sha

  robot.respond /commit\s+([a-z0-9\-]+)\s+([a-f0-9]+)$/i, (msg) ->
    project = msg.match[1]
    sha = msg.match[2]
    msg.send "https://git.dev.pardot.com/Pardot/" + project + "/commit/" + sha

  robot.respond /diff\s+([^\s]+)$/i, (msg) ->
    branch = msg.match[1]
    msg.send "https://git.dev.pardot.com/Pardot/pardot/compare/" + branch.replace('/', ';') + "?w=1"

  robot.respond /diff\s+([^\s]+)\s+([^\s]+)$/i, (msg) ->
    branch1 = msg.match[1]
    branch2 = msg.match[2]
    diff = branch1.replace('/', ';') + "..." + branch2.replace('/', ';')
    msg.send "https://git.dev.pardot.com/Pardot/pardot/compare/" + diff + "?w=1"
