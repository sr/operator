# Description:
#   Shit you say on the internet
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot classic - get a classic tweet

fetchTweet = (msg, person) ->
  msg.http("http://favstar.fm/users/#{person}")
    .get() (err, res, body) ->
      ids = []
      regex = new RegExp("id='tweet_(\\d+)'", 'gi')
      match = regex.exec(body)
      while match
        ids.push(match[1])
        match = regex.exec(body)
      return if ids.length is 0
      id = ids[Math.floor(Math.random() * ids.length)]
      msg.send("https://twitter.com/#{person}/status/#{id}")

module.exports = (robot) ->
  robot.respond /classic @?(\w+)/i, (msg) ->
    fetchTweet(msg, msg.match[1])
