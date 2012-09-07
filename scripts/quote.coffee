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

mysql = require "mysql"

mysqlClient = mysql.createClient({
    user: process.env.QUOTE_DB_USER,
    password: process.env.QUOTE_DB_PASSWORD,
    database: process.env.QUOTE_DB_DATABASE
});


module.exports = (robot) ->
    robot.hear /^!quote\s+(.*)$/i, (msg) ->
        key = msg.match[1]
        mysqlClient.query 'SELECT quote FROM quote WHERE quote like ' + mysqlClient.escape('%'+key+'%') + ' ORDER BY rand() limit 10', (err,r,f) ->
            msg.send r[0].quote if r

    robot.hear /^!quote$/i, (msg) ->
        mysqlClient.query 'SELECT quote FROM quote ORDER BY rand() limit 10', (err,r,f) ->
            msg.send r[0].quote if r

    robot.hear /^!addquote\s+(.*)/i, (msg) ->
        key = msg.match[1]
        mysqlClient.query 'INSERT INTO quote (quote) VALUES(?)', [key], (err,r,f) ->
            console.log err if err

        robot.send msg.message.user.name, 'Quote added!'

    robot.hear /^!delquote\s+(.*)/i, (msg) ->
        key = msg.match[1]
        mysqlClient.query 'DELETE FROM quote WHERE quote = ?', [key], (err,r,f) ->
            console.log err if err

         robot.send msg.message.user.name, 'Quote deleted!'