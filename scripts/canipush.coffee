Request = require 'request'

module.exports = (robot) ->
  if process.env.BOT_TYPE == 'internbot'
    return

  robot.hear /^!canipush/i, (msg) ->
    Request.get 'http://pardot-canipush.herokuapp.com/simple', (err, res, body) ->
      if body is "yes"
        msg.send "(successful) Push away!"
      else
        msg.send "(failed) Don't push right now!!"
