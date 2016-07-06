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
#
# Author:
#   Kelvin Chen

Markov = require '../lib/markov'

module.exports = (robot) ->
	client = new Markov()

	robot.respond /markov\s+(.*)$/i, (res) ->
		client.generate res.match[1], (err, text) ->
			res.send(text) if not err
