# Description:
#   Dickbuttme is not the most important thing in your life
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   dickbutt me - Receive a pug
#   dickbutt bomb N - get N pugs
#
# Author:
#   @keefkeef

module.exports = (robot) ->
  robot.respond /dickbutt\sme)/i, (msg) ->
    imageMe msg, "dickbutt", (url) ->
      msg.send "#{url}"

  robot.respond /dickbutt bomb( (\d+))?/i, (msg) ->
    count = msg.match[2] || 3
    i for i in [1..count]
      imageMe msg, "dickbutt", (url) ->
        msg.send "#{url}"

imageMe = (msg, query, cb) ->
  msg.http('http://ajax.googleapis.com/ajax/services/search/images')
  .query(v: "1.0", rsz: '8', q: query)
  .get() (err, res, body) ->
    images = JSON.parse(body)
    images = images.responseData.results
    image  = msg.random images
    cb "#{image.unescapedUrl}#.png"
