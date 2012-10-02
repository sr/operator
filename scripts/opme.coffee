# Description:
#   Basic Parbot utils
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   None
#

util = require "../lib/util"

module.exports = (robot) ->
    robot.hear /^!opme\s+(.*)/i, (msg) ->
        target = msg.match[1]
        robot.adapter.command('MODE', target, '+o', msg.message.user.name);

