Request = require 'request'
Cheerio = require 'cheerio'

url = 'http://dynamic.xkcd.com/random/comic/'

module.exports = (robot) ->
  if process.env.BOT_TYPE != 'internbot'
    return

  robot.hear /xkcd/i, (msg) ->
    Request.get url, (err, res, body) ->
      msg.send res.request.href
