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
#   fooery - parbot commands
#

util = require "../lib/util"

module.exports = (robot) ->
    # Find release infos
    robot.hear /^!lastrelease\s*(\d*)/i, (msg) ->
        number = msg.match[1]
        conn = util.getReleaseDBConn()

        if not number
            conn.query 'SELECT * FROM sync ORDER BY ID DESC limit 1', (err,r,f) ->
                if r and r[0]
                    msg.send r[0].releaser + ' updated prod from revision ' + r[0].revision + ' on ' + r[0].date
        else
            conn.query 'SELECT * FROM sync ORDER BY ID DESC limit ' + number, (err,r,f) ->
                if r and r[0]
                    for sync in r
                        msg.send sync.releaser + ' updated prod from revision ' + sync.revision + ' on ' + sync.date

        conn.end()

