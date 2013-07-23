Request = require 'request'

module.exports = (robot) ->
  if process.env.BOT_TYPE == 'internbot'
    return

  robot.hear /aww/i, (msg) ->
    Request.get 'http://www.reddit.com/r/aww.json', (err, res, body) ->
      result = JSON.parse(body) if typeof body is 'string'

      if result.data.children.count <= 0
        msg.send "Couldn't find anything cute..."
        return

      urls = [ ]
      for child in result.data.children
        urls.push(child.data.url)

      rnd = Math.floor(Math.random()*urls.length)
      #msg.send urls[rnd]
