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

            if not number
                number = 1
            if number > 10
                number = 10
            if number < 1
                number = 1

            conn = util.getReleaseDBConn()
            conn.query 'SELECT * FROM sync ORDER BY ID DESC limit ' + number, (err,r,f) ->
                if r and r[0]
                    for sync in r
                        github_link = 'https://github.com/pardot/pardot/tree/build' + sync.revision
                        msg.send sync.releaser + ' synced tag "build' + sync.revision + '" (' + github_link + ') to production on ' + sync.date
                else
                    msg.send 'Unable to find previous releases at the moment...'

            conn.end()

    robot.hear /^!lastbuild\s*(\d*)/i, (msg) ->
        if process.env.BOT_TYPE == 'parbot'
            number = msg.match[1]

            if not number
                number = 1
            if number > 10
                number = 10
            if number < 1
                number = 1

            conn = util.getReleaseDBConn()
            conn.query 'SELECT * FROM builds ORDER BY ID DESC limit ' + number, (err,r,f) ->
                if r and r[0]
                    for build in r
                        github_link = 'https://github.com/pardot/pardot/tree/build' + build.build_number
                        msg.send 'build' + build.build_number + ' (' + github_link + ') passed on ' + build.date
                else
                    msg.send 'Unable to find previous builds at the moment...'

            conn.end()


    # [image] Pardot › Application Pipeline › #541 passed. 1580 passed. Changes by Joe Winegarden
    # testable link for regex : http://rubular.com/r/OQw3IvAFda

    # CREATE TABLE IF NOT EXISTS `builds` (
    #   `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
    #   `build_number` int(11) DEFAULT NULL,
    #   `date` datetime DEFAULT NULL,
    #   PRIMARY KEY (`id`)
    # ) ENGINE=InnoDB AUTO_INCREMENT=1019 DEFAULT CHARSET=utf8;
    robot.hear /Pardot . Application Pipeline . \#(\d*)[^\d]*? passed\./, (msg) ->
        if process.env.BOT_TYPE == 'parbot'
            build_number = msg.match[1]
            # github_link = 'https://github.com/pardot/pardot/tree/build' + build_number

            conn = util.getReleaseDBConn()
            conn.query 'INSERT INTO builds (build_number, date) VALUES(?, NOW())', [build_number], (err,r,f) ->
                if err
                    console.log err

            conn.end()


    # PROD: is just finished syncing Pardot to build537 on email-d1.pardot.com
    # testable link for regex : http://rubular.com/r/kqYwQ7ztFS

    # CREATE TABLE IF NOT EXISTS `sync` (
    #   `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
    #   `releaser` varchar(50) DEFAULT '',
    #   `revision` int(11) DEFAULT NULL,
    #   `date` datetime DEFAULT NULL,
    #   PRIMARY KEY (`id`)
    # ) ENGINE=InnoDB AUTO_INCREMENT=1019 DEFAULT CHARSET=utf8;
    robot.hear /^PROD\: (\w+) just began syncing Pardot to .*?build(\d+).*? on ([\w\.\-]*)/, (msg) ->
        if process.env.BOT_TYPE == 'parbot'
            syncmaster = msg.match[1]
            build_number = msg.match[2]

            conn = util.getReleaseDBConn()
            conn.query 'INSERT INTO sync (releaser, revision, date) VALUES(?, ?, NOW())', [syncmaster, build_number], (err,r,f) ->
                if err
                    console.log err

            conn.end()
