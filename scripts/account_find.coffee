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
    robot.hear /^!account\s+(\d*)$/i, (msg) ->
        account_id = msg.match[1]
        util.apiGetAccountInfo account_id, msg

    robot.hear /^!account\s+([a-z].*)$/i, (msg) ->
        search_text = msg.match[1]
        util.apiGetAccountsLike search_text, msg