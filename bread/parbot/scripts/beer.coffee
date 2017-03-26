# Description
#   Searches brewerydb.com for beers and breweries
#
# Configuration:
#   HUBOT_BREWERYDB_KEY
#
# Commands:
#   hubot beer random - Finds information about a random beer
#   hubot beer <beer name> - Finds information about a beer
#   hubot brewery random - Finds information about a brewery
#   hubot brewery <brewery name> - Finds information about a brewery
#   hubot cheers || salud || salut || prost || <cheers in other languages>
#
# Author:
#   Thor

_ = require "underscore"

module.exports = (robot) ->
  url_search="http://api.brewerydb.com/v2/search"
  key = process.env.HUBOT_BREWERYDB_KEY

  robot.respond /beer(?:\s)+(.+)/i, (msg) ->
    beer_handler msg, key, url_search

  robot.respond /brewery(?:\s)+(.+)/i, (msg) ->
    brewery_handler msg, key, url_search

  robot.respond /cheers|salud|salute?|prosi?t|broscht|g'?sundheit|sante|viva|'?iwlIj jachjaj|valar m(ō|o)zussis$/i, (msg) ->
    msg.send "(beer)"

beer_handler = (msg, key, url) ->

  unless msg.match?[1]?.trim()?
    return

  unless key?
    msg.send "API key not set. Panic!"
    return

  query =
    format: "json",
    key: key,
    withBreweries: "Y"

  if msg.match?[1]?.trim().toLowerCase() != 'random'
    _.extend query,
      q: msg.match[1].trim(),
      type: "beer"
  else
    url="http://api.brewerydb.com/v2/beer/random"

  msg.http(url).query(query).get() (err, res, body) ->

    data = JSON.parse(body).data

    if data?.id?
      beer = data
    else if data?[0]?
      beer = data[0]
    else
      msg.send "Unfortunately, my knowledge still has limits."
      return

    html = "<strong><i>#{beer.name}</i></strong><br />"
    if beer.breweries?[0]?
      html += "<strong>Brewery:</strong> #{beer.breweries[0].name}<br />"
    if beer.abv?
      html += "<strong>ABV:</strong> #{beer.abv}%<br />"
    if beer.description?
      html += "<strong>Description:</strong> #{beer.description}<br />"
    if beer.style?.name?
      html += "<strong>Style:</strong> #{beer.style.name}<br />"
    if beer.glass?.name?
      html += "<strong>Glass Style:</strong> #{beer.glass.name}"

    msg.hipchatNotify(html, {color: "gray"})

brewery_handler = (msg, key, url) ->

  unless msg.match?[1]?.trim()?
    return

  unless key?
    msg.send "API key not set. Panic!"
    return

  query =
    format: "json",
    key: key

  if msg.match?[1]?.trim().toLowerCase() != 'random'
    _.extend query,
      q: msg.match[1].trim(),
      type: "brewery"
  else
    url="http://api.brewerydb.com/v2/brewery/random"

  msg.http(url).query(query).get() (err, res, body) ->
    data = JSON.parse(body).data

    if data?.id?
      brewery = data
    else if data?[0]?
      brewery = data[0]
    else
      msg.send "Unfortunately, my knowledge still has limits."
      return

    html = "<strong><i>#{brewery.name}</i></strong><br />"
    if brewery.description?
      html += "<strong>Description:</strong> #{brewery.description}<br />"
    if brewery.website?
      html += "<strong>Website:</strong> <a href=\"#{brewery.website}\">#{brewery.website}</a><br />"
    if brewery.established?
      html += "<strong>Established:</strong> #{brewery.established}"

    msg.hipchatNotify(html, {color: "gray"})
