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
    robot.hear /^!quote\s+(.*)$/i, (msg) ->
        key = msg.match[1]
        conn = util.getQuoteDBConn()
        conn.query 'SELECT quote FROM quote WHERE quote like ' + conn.escape('%'+key+'%') + ' ORDER BY rand() limit 10', (err,r,f) ->
            msg.send r[0].quote if r and r[0]

    robot.hear /^!quote$/i, (msg) ->
        util.getQuoteDBConn().query 'SELECT quote FROM quote ORDER BY rand() limit 10', (err,r,f) ->
            msg.send r[0].quote if r and r[0]

    robot.hear /^!addquote\s+(.*)$/i, (msg) ->
        key = msg.match[1]
        util.getQuoteDBConn().query 'INSERT INTO quote (quote) VALUES(?)', [key], (err,r,f) ->
            return console.log err if err
            robot.send msg.message.user.name, 'Quote added!'

    robot.hear /^!delquote\s+(.*)$/i, (msg) ->
        key = msg.match[1]
        util.getQuoteDBConn().query 'DELETE FROM quote WHERE quote = ?', [key], (err,r,f) ->
            return console.log err if err
            robot.send msg.message.user.name, 'Quote deleted!'