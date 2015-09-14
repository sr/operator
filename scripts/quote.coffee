# Description:
#   Maintains a list of quotable quotes
#
# Dependencies:
#   mysql
#
# Configuration:
#   DATABASE_URL
#
# Commands:
#   hubot joke - Returns a quote by ian
#   hubot quote - Returns a random quote
#   hubot quote <quote> - Returns a random quote containing <quote>
#   hubot addquote <nick> <quote> - Adds a quote to the database
#   hubot delquote <quote> - Removes a quote from the database

quotes = require "../lib/quotes"

module.exports = (robot) ->
  client = quotes.createClient()

  robot.respond /joke$/i, (msg) ->
    client.random 1, "<ian>", (err, r) ->
      msg.send r[0].quote if r and r[0]

  robot.respond /quote\s+(.*)$/i, (msg) ->
    client.random 1, msg.match[1], (err, r) ->
      msg.send r[0].quote if r and r[0]

  robot.respond /quote$/i, (msg) ->
    client.random 1, null, (err, r) ->
      msg.send r[0].quote if r and r[0]

  robot.respond /addquote\s+(.*)$/i, (msg) ->
    client.add msg.match[1], (err, r, f) ->
      if err
        console.log err
        msg.send 'Something went wrong. (sadpanda)'
      else
        msg.send 'OK, added. (buttrock)'

  robot.respond /delquote\s+(.*)$/i, (msg) ->
    client.delete msg.match[1], (err, r, f) ->
      if err
        console.log err
        msg.send 'Something went wrong. (sadpanda)'
      else
        msg.send 'OK, deleted. (sadpanda)'
