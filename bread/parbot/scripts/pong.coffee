# Description:
#   Interface to the pong automation system
#
# Dependencies:
#   the internet? I guess?
#
# Configuration:
#   None
#
# Commands:
#   hubot pong status - Returns the status of the current game in the default room

pongApiUrl = 'https://pardot-pingpong.herokuapp.com/api/'
#pongApiUrl = 'http://localhost:3000/api/'

getPlayerString = (playerNameArray, teamId) ->
  if playerNameArray.length > 1
    return playerNameArray.join(' and ')
  else if playerNameArray.length == 1
    return playerNameArray[0]
  else
    return "team #{teamId}"

module.exports = (robot) ->
  robot.respond /pong\s*(?:status)*$/i, (msg) ->
    url = pongApiUrl + 'rooms/1/status'
    robot.http(url)
      .get() (error, response, body) ->
        if error
          msg.send "Pong server failed to respond: #{error}"
        else
          payload = JSON.parse(body)
          if payload.has_active_game
            out = "#{payload.name} status: "
            teamAString = getPlayerString(payload.player_data.team_a, 'a')
            teamBString = getPlayerString(payload.player_data.team_b, 'b')

            if payload.team_a_score > payload.team_b_score
              out += teamAString + ' beating ' +
                  teamBString + ' ' + payload.team_a_score + ' to ' + payload.team_b_score
            else if payload.team_b_score > payload.team_a_score
              out += teamBString + ' beating ' +
                  teamAString + ' ' + payload.team_b_score + ' to ' + payload.team_a_score
            else
              # Tie
              out += teamAString + ' and ' + teamBString + ' are tied at ' + payload.team_a_score
            if payload.hasOwnProperty('game_count')
              out += ", playing game #{payload.game_count}"
            msg.send out
          else
            msg.send 'Pong room unoccupied'
