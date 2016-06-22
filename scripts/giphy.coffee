# Description:
#   A way to search images on giphy.com
#
# Configuration:
#   HUBOT_GIPHY_API_KEY
#
# Commands:
#   hubot gif me <query> - returns a pg gif from giphy 

giphy =
  #api_key: 'dc6zaTOxFJmzC' #<- testing api key
  api_key: process.env.HUBOT_GIPHY_API_KEY
  url: 'http://api.giphy.com/v1/gifs/search'

module.exports = (robot) ->
  robot.respond /(gif|giphy)( me)? (.*)/i, (msg) ->
    query = msg.match[3]

    msg.http(giphy.url)
      .query
        q: query
        rating: "pg"
        api_key: giphy.api_key
      .get() (err, res, body) ->
        if not err
          try
            response = JSON.parse(body)
            images = response.data
            if images.length > 0
              image = msg.random images
              msg.send image.images.original.url
          catch e
            msg.send "Bad Response: #{e}"
        else 
            msg.send "Error: #{e}"
