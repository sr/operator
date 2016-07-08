# Description:
#   A way to search videos on youtube.com
#
# Configuration:
#   None
#
# Commands:
#   hubot youtube <query> - returns a video from youtube 

#https://developers.google.com/youtube/v3/docs/search/list
GOOGLE_API_KEY = "AIzaSyCuiCcMIpCNlk6h6EYl_iB0iGpoYsyBUIM"

module.exports = (robot) ->
  robot.respond /youtube\s+(.*)\s*/i, (msg) ->
    query = msg.match[1]
    
    url = "https://www.googleapis.com/youtube/v3/search"  
    msg.http(url)
      .query
        part: "snippet"
        maxResults: 1
        order: "relevance"
        safeSearch: "moderate"
        type: "video"
        q: query
        rating: "pg"
        key: GOOGLE_API_KEY
      .get() (err, res, body) ->
        if not err
          try
            response = JSON.parse(body)
            videoId = response?.items[0]?.id?.videoId
            videoUrl = "https://www.youtube.com/watch?v=#{videoId}"
            msg.send videoUrl  
          catch e
            msg.send "#{e}"
        else
          msg.send "#{err}"
