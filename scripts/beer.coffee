# Description
#   Searches brewerydb.com for beers and breweries
#
# Configuration:
#   BREWERYDB_KEY
#
# Commands:
#   ! beer || beer me <beer name> - Finds information about beers
#   ! brewery || brewery me <brewery name> - Finds information about breweries
#   ! cheers || salud || salut || prost || <cheers in other languages>
#
# Author:
#   Thor

module.exports = (robot) ->

  url="http://api.brewerydb.com/v2/search"
  key = process.env.BREWERYDB_KEY

  robot.respond /beer(?:\s)(?:me)?(?:\s)?(.*)/i, (msg) ->
    beer_me msg, key, url

  robot.respond /brewery(?:\s)(?:me)?(?:\s)?(.*)/i, (msg) ->
    brewery_me msg, key, url

  robot.respond /cheers|salud|salute?|prosi?t|broscht|g'?sundheit|sante|viva|'?iwlIj jachjaj|valar m(ō|o)zussis$/i, (msg) ->
    msg.send "(beer)"

beer_me = (msg, key, url) ->
  unless key?
    msg.send "API key not set. Panic!"
    return

  query = { q: msg.match[1].replace(" ", "+"), key: key, format: "json", type: "beer" }

  msg.http(url).query(query).get() (err, res, body) ->
    data = JSON.parse(body)['data']

    if data
      beer = data[0]
    else
      msg.send "Unfortunately, my knowledge still has limits."
      return
    
    html = "<strong><i>#{beer['name']}</i></strong><br />"
    if beer['abv']?
      html += "<strong>ABV:</strong> #{beer['abv']}%<br />"
    if beer['description']?
      html += "<strong>Description:</strong> #{beer['description']}<br />"
    if beer['style']?
      html += "<strong>Style:</strong> #{beer['style']['name']}<br />"
    if beer['glass']?
      html += "<strong>Glass Style:</strong> #{beer['glass']['name']}<br />"

    msg.hipchatNotify(html, {color: "gray"})
    

brewery_me = (msg, key, url) ->
  unless key?
    msg.send "API key not set. Panic!"
    return

  query = { q: msg.match[1].replace(" ", "+"), key: key, format: "json", type: "brewery" }
  msg.http(url).query(query).get() (err, res, body) ->
    data = JSON.parse(body)['data']

    if data
      brewery = data[0]
    else
      msg.send "Unfortunately, my knowledge still has limits."
      return

    html = "<strong><i>#{brewery['name']}</i></strong><br />"
    if brewery['description']?
      html += "<strong>Description:</strong> #{brewery['description']}<br />"
    if brewery['website']?
      html += "<strong>Website:</strong> <a href=\"#{brewery['website']}\">#{brewery['website']}</a><br />"
    if brewery['established']?
      html += "<strong>Established:</strong> #{brewery['established']}<br />"

    msg.hipchatNotify(html, {color: "gray"})
