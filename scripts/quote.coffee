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
    robot.hear /^!joke$/i, (msg) ->
        if process.env.BOT_TYPE == 'parbot'
            key = msg.match[1]
            conn = util.getQuoteDBConn()
            conn.query 'SELECT quote FROM quote WHERE quote like \'%<ian>%\' ORDER BY rand() limit 10', (err,r,f) ->
                msg.send r[0].quote if r and r[0]

            conn.end()

    robot.hear /^!quote\s+(.*)$/i, (msg) ->
        key = msg.match[1]
        conn = util.getQuoteDBConn()
        conn.query 'SELECT quote FROM quote WHERE quote like ' + conn.escape('%'+key+'%') + ' ORDER BY rand() limit 10', (err,r,f) ->
            msg.send r[0].quote if r and r[0]

        conn.end()

    robot.hear /^!quote$/i, (msg) ->
        conn = util.getQuoteDBConn()
        conn.query 'SELECT quote FROM quote ORDER BY rand() limit 10', (err,r,f) ->
            msg.send r[0].quote if r and r[0]

        conn.end()

    robot.hear /^!addquote\s+(.*)$/i, (msg) ->
        key = msg.match[1]
        conn = util.getQuoteDBConn()
        conn.query 'INSERT INTO quote (quote) VALUES(?)', [key], (err,r,f) ->
            if err
                conn.end()
                return console.log err
            else
                msg.send 'OK, added. (buttrock)'
                # robot.send msg.message.user.name, 'Quote added!'

        conn.end()

    robot.hear /^!delquote\s+(.*)$/i, (msg) ->
        key = msg.match[1]
        conn = util.getQuoteDBConn()
        conn.query 'DELETE FROM quote WHERE quote = ?', [key], (err,r,f) ->
            if err
                conn.end()
                return console.log err
            else
                msg.send 'OK, deleted. (sadpanda)'
                # robot.send msg.message.user.name, 'Quote deleted!'

        conn.end()
