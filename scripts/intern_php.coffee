Request = require 'request'
Cheerio = require 'cheerio'

clean = (str) ->
  str.replace(/(\s|\r|\n)+/g, ' ').replace(/(^\s)|(\s$)/g, '')

module.exports = (robot) ->
  if process.env.BOT_TYPE != 'internbot'
    return

  robot.hear /^!php (.*)$/, (msg) ->
    search = msg.match[1].replace /_/g, '-'
    url = "http://us2.php.net/manual/en/function.#{search}.php"

    Request.get url, (err, res, body) ->
      if res.statusCode isnt 200 or not /text\/html/.test res.headers['content-type']
        return msg.send 'Could not find a page for that php function'

      $ = Cheerio.load body
      proto = clean $('div.methodsynopsis.dc-description').text()
      desc = clean $('p.para.rdfs-comment').text()

      msg.send proto
      msg.send desc
      msg.send "(#{url})"

