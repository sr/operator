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
    if process.env.BOT_TYPE != 'parbot'
        return

    # Find release infos
    robot.hear /^!lastrelease\s*(\d*)/i, (msg) ->
        if process.env.BOT_TYPE == 'parbot'
            number = msg.match[1]
            conn = util.getReleaseDBConn()

            if number > 10
                number = 10

            if not number
                conn.query 'SELECT * FROM sync ORDER BY ID DESC limit 1', (err,r,f) ->
                    if r and r[0]
                        msg.send r[0].releaser + ' synced tag "build' + r[0].revision + '" to production on ' + r[0].date
            else
                conn.query 'SELECT * FROM sync ORDER BY ID DESC limit ' + number, (err,r,f) ->
                    if r and r[0]
                        for sync in r
                            msg.send sync.releaser + ' synced tag "build' + sync.revision + '" to production on ' + sync.date

            conn.end()

    # [image] Pardot › Application Pipeline › #541 passed. 1580 passed. Changes by Joe Winegarden
    # testable link for regex : http://rubular.com/r/OQw3IvAFda
    robot.hear /Pardot . Application Pipeline . \#(\d*)[^\d]*? passed\./, (msg) ->
        if process.env.BOT_TYPE == 'parbot'
            build_number = msg.match[1]
            github_link = 'https://github.com/pardot/pardot/tree/build' + build_number

            msg.send 'Sounds like build' + build_number + ' (' + github_link + ') just passed [TEST IGNORE] << @veader'


    # PROD: is just finished syncing Pardot to build537 on email-d1.pardot.com
    # testable link for regex : http://rubular.com/r/kqYwQ7ztFS
    robot.hear /^PROD\: (\w+) just began syncing Pardot to .*?build(\d+).*? on ([\w\.\-]*)/, (msg) ->
        if process.env.BOT_TYPE == 'parbot'
            syncmaster = msg.match[1]
            build_number = msg.match[2]

            msg.send 'Sounds like ' + syncmaster + ' just began a pooosh of build' + build_number + '  [TEST IGNORE] << @veader'
