# Description
#   A hubot script returning the time until the next MARTA train to Lenox station given a direction.
#
# Configuration:
#   HUBOT_MARTA_API_KEY
#
# Commands
#   hubot train north - returns time until next northbound train
#   hubot train south - returns time until next southbound train
#
# Author:
#   Jake Swanson (https://github.com/jakswa/hubot-marta)
#   Akshay Easwaran <aeaswaran@salesforce.com> (who modified this to focus only on the Lenox station)
#

marta_api_key = process.env.HUBOT_MARTA_API_KEY
marta_trains_url = 'http://developer.itsmarta.com/RealtimeTrain/RestServiceNextTrain/GetRealtimeArrivals?apiKey='

request = require('request')
moment = require('moment')
_ = require('underscore')

arrivals = []
getArrivals = (callback) ->
  unless marta_api_key
    callback "No API KEY :("
    return

  request marta_trains_url + marta_api_key, (err, resp, body) ->
    arrivals = JSON.parse(body)
    callback()

filterArrivals = (opts={}) ->
  destRegex = new RegExp(opts.destination, 'i')
  stationRegex = new RegExp(opts.station, 'i')
  filtered = arrivals
  filtered = _.filter(filtered, (arrival) -> arrival.DIRECTION == opts.direction.charAt(0).toUpperCase()) if opts.direction
  filtered = _.filter(filtered, (arrival) -> arrival.LINE == opts.line.toUpperCase()) if opts.line
  filtered = _.filter(filtered, (arrival) -> arrival.DESTINATION.match(destRegex)) if opts.destination
  filtered = _.filter(filtered, (arrival) -> arrival.STATION.match(stationRegex)) if opts.station
  filtered

dirMap =
  S: 'south'
  E: 'east'
  N: 'north'
  W: 'west'

capitalize = (string) ->
  return string[0].toUpperCase() + string.slice(1).toLowerCase()

module.exports = (robot) ->
  robot.respond /train\s+(.*)$/i, (msg) ->
    if msg.match[1].toLowerCase() == 'pardot'
      msg.send '(nyantrain)'
      return
    else if msg.match[1].toLowerCase() == 'west' || msg.match[1].toLowerCase() == 'east' || msg.match[1].toLowerCase() == 'southeast' || msg.match[1].toLowerCase() == 'northeast' || msg.match[1].toLowerCase() == 'southwest' || msg.match[1].toLowerCase() == 'northwest'
      msg.send "(marta) There are no trains going #{msg.match[1]} to or from Lenox. (sadpanda)"
      return

    getArrivals (err)->
      if err
        msg.send err
        return
      dir = 'south'
      dest = 'airport'
      if (msg.match[1].toLowerCase() == 'north' || msg.match[1].toLowerCase() == 'northbound')
        dir = 'north'
        dest = 'doraville'
      trains = filterArrivals(
        direction: dir,
        line: 'gold',
        station: 'lenox',
        destination: dest
      )

      train = trains.shift()
      if train
        arrival_text = "will arrive"
        arrival_text = "started boarding" if train.WAITING_TIME == 'Boarding'
        direction = dirMap[train.DIRECTION]
        next_arrival = moment().add(parseInt(train.WAITING_SECONDS),'seconds')
        msg.send "(marta) Next #{direction}bound train #{arrival_text} at #{capitalize(train.STATION).replace('station','')}#{next_arrival.fromNow()}."
      else
        msg.send "(marta) No trains found headed #{dir} towards #{capitalize(dest)}. (sadpanda)"
