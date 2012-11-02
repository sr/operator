# Description:
#   Handle quoting
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
    robot.hear /^!account\s+(.*)$/i, (msg) ->
        account_id = msg.match[1]
        util.apiGetAccountInfo account_id, msg
