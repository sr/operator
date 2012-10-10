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
    # Find release infos
    robot.hear /^!lastrelease\s*(\d*)/i, (msg) ->
        number = msg.match[1]

        if not number
            util.getReleaseDBConn().query 'SELECT * FROM release ORDER BY ID DESC limit 1', (err,r,f) ->
                msg.send r[0].quote if r and r[0]
        else
            console.log 'fooey'
            util.getReleaseDBConn().query 'SELECT * FROM release ORDER BY ID DESC limit ?', [number], (err,r,f) ->
                msg.send r[0].quote if r and r[0]

