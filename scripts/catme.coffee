# Description:
#   Catme is a cheap imitation of the most important thing in your life
#
# Dependencies:
#   a theCatAPI API key: MzY3NTA
#
# Configuration:
#   None
#
# Commands:
#   cat me - Receive a cat
#   cat bomb N - get (N|3) cats
#   cat gif me - Receive a cat gif
#   cat gif bomb N - get (N|3) cat gifs
#   cat hat me - Receive a cat in a hat
#   cat hat bomb N - get (N|3) cats in a hat


module.exports = (robot) ->

  robot.hear /cat me/i, (msg) ->
    msg.http("http://thecatapi.com/api/images/get?api_key=MzY3NTA&format=xml&type=jpg,png&results_per_page=1")
    .get() (err, res, body) ->
      lines=body.split("\n")
      msg.send line.split(">")[1].split("<")[0] for line in lines when line.match("<url>")

  robot.hear /cat bomb( (\d+))?/i, (msg) ->
    count = msg.match[2] || 3
    msg.http("http://thecatapi.com/api/images/get?api_key=MzY3NTA&format=xml&type=jpg,png&results_per_page=" + count)
    .get() (err, res, body) ->
      lines=body.split("\n")
      msg.send line.split(">")[1].split("<")[0] for line in lines when line.match("<url>")

  robot.hear /cat gif me/i, (msg) ->
    msg.http("http://thecatapi.com/api/images/get?api_key=MzY3NTA&format=xml&type=gif&results_per_page=1")
    .get() (err, res, body) ->
      lines=body.split("\n")
      msg.send line.split(">")[1].split("<")[0] for line in lines when line.match("<url>")

  robot.hear /cat gif bomb( (\d+))?/i, (msg) ->
    count = msg.match[2] || 3
    msg.http("http://thecatapi.com/api/images/get?api_key=MzY3NTA&format=xml&type=gif&results_per_page=" + count)
    .get() (err, res, body) ->
      lines=body.split("\n")
      msg.send line.split(">")[1].split("<")[0] for line in lines when line.match("<url>")

  robot.hear /cat hat me/i, (msg) ->
    msg.http("http://thecatapi.com/api/images/get?api_key=MzY3NTA&format=xml&type=jpg,png&category=hats&results_per_page=1")
    .get() (err, res, body) ->
      lines=body.split("\n")
      msg.send line.split(">")[1].split("<")[0] for line in lines when line.match("<url>")

  robot.hear /cat hat bomb( (\d+))?/i, (msg) ->
    count = msg.match[2] || 3
    msg.http("http://thecatapi.com/api/images/get?api_key=MzY3NTA&format=xml&type=jpg,png&category=hats&results_per_page=" + count)
    .get() (err, res, body) ->
      lines=body.split("\n")
      msg.send line.split(">")[1].split("<")[0] for line in lines when line.match("<url>")

