# Description:
#   Retrieves random chatty facts.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   chattyfact - Reply back with random chatty fact.
#
# Author:
#   parkermcgee

module.exports = (robot) ->
  robot.respond /chattyfact/i, (msg) ->
    msg.http('http://api.icndb.com/jokes/random')
      .get() (error, response, body) ->
        # passes back the complete reponse
        response = JSON.parse(body)
        if response.type == "success"
          msg.send response.value.joke.replace /Chuck Norris/g, "Chatty"
        else
          msg.send "Unable to get chatty facts right now."
