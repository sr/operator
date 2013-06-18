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
#   !commit <sha> - responds with the commit url
#
# Author:
#   parkermcgee

module.exports = (robot) ->
    robot.hear /!commit\s+([a-f0-9]+)$/i, (msg) ->
        sha = msg.match[1]
        msg.send "https://github.com/Pardot/pardot/commit/" + sha

    robot.hear /!commit\s+([a-z0-9\-]+)\s+([a-f0-9]+)$/i, (msg) ->
        project = msg.match[1]
        sha = msg.match[2]
        msg.send "https://github.com/Pardot/" + project + "/commit/" + sha

    robot.hear /!diff\s+([^\s]+)$/i, (msg) ->
        branch = msg.match[1]
        msg.send "https://github.com/Pardot/pardot/compare/" + branch.replace('/', ';')

    robot.hear /!diff\s+([^\s]+)\s+([^\s]+)$/i, (msg) ->
        branch1 = msg.match[1]
        branch2 = msg.match[2]
        diff = branch1.replace('/', ';') + "..." + branch2.replace('/', ';')
        msg.send "https://github.com/Pardot/pardot/compare/" + diff
