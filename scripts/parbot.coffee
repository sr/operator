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
#   fooey - parbot commands
#

util = require "../lib/util"

module.exports = (robot) ->
    # Find release infos
    robot.hear /^!lastrelease\s*(\d*)/i, (msg) ->
        if process.env.RELEASE_TRACKING_ENABLED == 'true'
            number = msg.match[1]
            conn = util.getReleaseDBConn()

            if number > 10
                number = 10

            if not number
                conn.query 'SELECT * FROM sync ORDER BY ID DESC limit 1', (err,r,f) ->
                    if r and r[0]
                        msg.send r[0].releaser + ' synced revision ' + r[0].revision + ' to production on ' + r[0].date
            else
                conn.query 'SELECT * FROM sync ORDER BY ID DESC limit ' + number, (err,r,f) ->
                    if r and r[0]
                        for sync in r
                            msg.send sync.releaser + ' synced revision ' + sync.revision + ' to production on ' + sync.date

            conn.end()