# Description:
#   Markov-chain text generator using the quotes database as the seed
#
# Dependencies:
#   mysql
#
# Configuration:
#   DATABASE_URL
#
# Commands:
#   hubot markov <text> - Generates text from the Markov model using a key found in <text>
#   hubot reseedmarkov  - Reseed the markov object
#
# Author:
#   Kelvin Chen

Markov = require '../lib/markov'

module.exports = (robot) ->
  client = new Markov()

  robot.respond /markov\s+(.*)$/i, (res) ->
    client.generateResponse(res.match[1])
      .then (txt) -> res.send(txt)

  robot.respond /reseedmarkov/i, (res) ->
    client.reseed()
    res.send 'Markov chain reseeded!'
