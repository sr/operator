# She'll be right back of bourke no worries get a dog up ya brass razoo.

module.exports = (robot) ->
  robot.respond /bogan( me)?/, (msg) ->
    robot.http("https://charlie.bz/cgi-bin/bogan-ipsum.rb").get() (err, res, body) ->
        msg.send body
