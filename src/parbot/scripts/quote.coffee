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

roomSpecificContexts =
  "support": "support"
  "not_solutions_for_work": "support"

contextForRoom = (room) ->
  if context = roomSpecificContexts[room]
    context
  else
    "engineering"

module.exports = (robot) ->
  client = quotes.createClient()

  robot.respond /joke$/i, (msg) ->
    client.random contextForRoom(msg.message.room), 1, "<ian>", (err, r) ->
      msg.send r[0].quote if r and r[0]

  robot.respond /quote\s+(.*)$/i, (msg) ->
    client.random contextForRoom(msg.message.room), 1, msg.match[1], (err, r) ->
      msg.send r[0].quote if r and r[0]

  robot.respond /quote$/i, (msg) ->
    client.random contextForRoom(msg.message.room), 1, null, (err, r) ->
      msg.send r[0].quote if r and r[0]

  robot.respond /addquote\s+(.*)$/i, (msg) ->
    client.add contextForRoom(msg.message.room), msg.match[1], (err, r, f) ->
      if err
        console.log err
        msg.send 'Something went wrong. (sadpanda)'
      else
        msg.send 'OK, added. (buttrock)'

  robot.respond /delquote\s+(.*)$/i, (msg) ->
    client.delete contextForRoom(msg.message.room), msg.match[1], (err, r, f) ->
      if err
        console.log err
        msg.send 'Something went wrong. (sadpanda)'
      else
        msg.send 'OK, deleted. (sadpanda)'
