# From Syl
module.exports = (robot) ->
  robot.hear /!joke/i, (msg) ->
    msg.http('http://jokels.com/random_joke').get() (err, res, body) ->
      joke = JSON.parse(body).joke
      vote = joke.up_votes - joke.down_votes
      msg.send "#{ joke.question }"
      setTimeout ->
        msg.send "#{ joke.answer }"
       , 4000