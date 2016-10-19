# Description:
#   Catme is a cheap imitation of the most important thing in your life
#
# Configuration:
#   HUBOT_THECAT_API_KEY
#
# Commands:
#   hubot cat me - Receive a cat
#   hubot cat bomb N - get (N|3) cats
#   hubot cat gif me - Receive a cat gif
#   hubot cat gif bomb N - get (N|3) cat gifs
#   hubot cat hat me - Receive a cat in a hat
#   hubot cat hat bomb N - get (N|3) cats in a hat

api_key = process.env.HUBOT_THECAT_API_KEY

module.exports = (robot) ->
  robot.respond /cat me/i, (msg) ->
    msg.http("http://thecatapi.com/api/images/get?api_key=#{api_key}&format=xml&type=jpg,png&results_per_page=1")
    .get() (err, res, body) ->
      lines=body.split("\n")
      msg.send line.split(">")[1].split("<")[0] for line in lines when line.match("<url>")

  robot.respond /cat bomb( (\d+))?/i, (msg) ->
    count = msg.match[2] || 3
    msg.http("http://thecatapi.com/api/images/get?api_key=#{api_key}&format=xml&type=jpg,png&results_per_page=" + count)
    .get() (err, res, body) ->
      lines=body.split("\n")
      msg.send line.split(">")[1].split("<")[0] for line in lines when line.match("<url>")

  robot.respond /cat gif me/i, (msg) ->
    msg.http("http://thecatapi.com/api/images/get?api_key=#{api_key}&format=xml&type=gif&results_per_page=1")
    .get() (err, res, body) ->
      lines=body.split("\n")
      msg.send line.split(">")[1].split("<")[0] for line in lines when line.match("<url>")

  robot.respond /cat gif bomb( (\d+))?/i, (msg) ->
    count = msg.match[2] || 3
    msg.http("http://thecatapi.com/api/images/get?api_key=#{api_key}&format=xml&type=gif&results_per_page=" + count)
    .get() (err, res, body) ->
      lines=body.split("\n")
      msg.send line.split(">")[1].split("<")[0] for line in lines when line.match("<url>")

  robot.respond /cat hat me/i, (msg) ->
    msg.http("http://thecatapi.com/api/images/get?api_key=#{api_key}&format=xml&type=jpg,png&category=hats&results_per_page=1")
    .get() (err, res, body) ->
      lines=body.split("\n")
      msg.send line.split(">")[1].split("<")[0] for line in lines when line.match("<url>")

  robot.respond /cat hat bomb( (\d+))?/i, (msg) ->
    count = msg.match[2] || 3
    msg.http("http://thecatapi.com/api/images/get?api_key=#{api_key}&format=xml&type=jpg,png&category=hats&results_per_page=" + count)
    .get() (err, res, body) ->
      lines=body.split("\n")
      msg.send line.split(">")[1].split("<")[0] for line in lines when line.match("<url>")

##
## this works but the API is broken
##
## see:
##
#  robot.respond /kitten me/i, (msg) ->
#    msg.http("http://thecatapi.com/api/images/get?api_key=#{api_key}&format=xml&type=jpg,png&category=kittens&results_per_page=1")
#    .get() (err, res, body) ->
#      lines=body.split("\n")
#      msg.send line.split(">")[1].split("<")[0] for line in lines when line.match("<url>")
#
#  robot.respond /kitten bomb( (\d+))?/i, (msg) ->
#    count = msg.match[2] || 3
#    msg.http("http://thecatapi.com/api/images/get?api_key=#{api_key}&format=xml&type=jpg,png&category=kittens&results_per_page=" + count)
#    .get() (err, res, body) ->
#      lines=body.split("\n")
#      msg.send line.split(">")[1].split("<")[0] for line in lines when line.match("<url>")
