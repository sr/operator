# Description
#   A hubot script returning you the traffic time from the office to a given address, view current Atlanta traffic, or view current traffic in a given city.
# Commands
#   hubot traffic - returns image of current traffic conditions in Atlanta
#   hubot traffic <location> - returns image of current traffic conditions in the provided location
#   hubot traveltime <location> - returns current travel time to the provided location from the office
# Author:
#   Akshay Easwaran <aeaswaran@salesforce.com>
#

module.exports = (robot) ->
  robot.respond /!traffic$/i, (msg) ->
    msg.send "http://www.mapquestapi.com/staticmap/v4/getplacemap?key=Dc5YTA5AT2FgWvGmzsdPgivGbh4VEjuI&location=Atlanta,+GA&size=400,400&type=map&zoom=10&imagetype=png&scalebar=false&traffic=flow.png"

  robot.respond /!traffic\s+(.*)$/i, (msg) ->
    location = encodeURI(msg.match[1])
    trafficimg = "http://www.mapquestapi.com/staticmap/v4/getplacemap?key=Dc5YTA5AT2FgWvGmzsdPgivGbh4VEjuI&location=#{location}&size=400,400&type=map&zoom=10&imagetype=png&scalebar=false&traffic=flow.png"
    msg.send trafficimg

  robot.respond /!traveltime\s+(.*)$/i, (msg) ->
    secondloc = msg.match[1]
    firstloc = '950+East+Paces+Ferry+Road,Atlanta,GA'

    msg.http("https://maps.googleapis.com/maps/api/distancematrix/json")
       .query({origins: "#{firstloc}", destinations: "#{secondloc}", mode: "driving", departure_time: "now", key: ''})
       .header('Accept', 'application/json')
       .get() (err, res, body) ->
          if err
            msg.send "Error: #{err}"
          data = JSON.parse body
          if data.error_message
            msg.send "Error: #{data.error_message}"
          duration = if data?.rows[0]?.elements[0]?.duration_in_traffic then data?.rows[0]?.elements[0]?.duration_in_traffic?.text else data?.rows[0]?.elements[0]?.duration?.text
          if duration == null
            msg.send "Unable to retrieve travel time to #{secondloc}"
          else if typeof duration is 'undefined'
            msg.send "There is no route between #{secondloc} and the office."
          else
            msg.send "To get to #{data.destination_addresses[0]} from the office, it will take #{duration}."
