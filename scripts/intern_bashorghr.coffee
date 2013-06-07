Request = require 'request'
Cheerio = require 'cheerio'
{ TextMessage } = require 'hubot'
_ = require 'underscore'
#Badwords = require '../lib/badwords'

clean = (str) ->
  str.replace(/(\s|\r|\n)+/g, ' ').replace(/(^\s)|(\s$)/g, '')

getRandomInt = (min, max) ->
  return Math.floor(Math.random() * (max - min + 1)) + min

module.exports = (robot) ->
  if process.env.BOT_TYPE != 'internbot'
    return

  robot.hear /^!bash-hr$/, (msg) ->
    nick = msg.message.user.name

    Request.get "http://bash.org/?random", (err, res, body) ->
      return if res.statusCode isnt 200 or not /text\/html/.test res.headers['content-type']

      $ = Cheerio.load body

      quotes = $('.qt').map(-> $(this).text() )

      quote = _(quotes).chain()
        .shuffle()
        .find((quote) -> quote.split('\n').length <= 5)
        .value()

      return robot.adapter.bot.say(nick, quote)
