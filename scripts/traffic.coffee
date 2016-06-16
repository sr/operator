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
  robot.respond /traffic$/i, (msg) ->
    msg.send "http://www.mapquestapi.com/staticmap/v4/getplacemap?key=Dc5YTA5AT2FgWvGmzsdPgivGbh4VEjuI&location=Atlanta,+GA&size=400,400&type=map&zoom=10&imagetype=png&scalebar=false&traffic=flow.png"

  robot.respond /traffic\s+(.*)$/i, (msg) ->
    location = msg.match[1]
    if location == 'Pardot' || location == 'the office'
      msg.send "Look outside! (troll)"
    else
      trafficimg = "http://www.mapquestapi.com/staticmap/v4/getplacemap?key=Dc5YTA5AT2FgWvGmzsdPgivGbh4VEjuI&location=#{encodeURI(location)}&size=400,400&type=map&zoom=10&imagetype=png&scalebar=false&traffic=flow.png"
      msg.send trafficimg

  robot.respond /traveltime\s+(.*)$/i, (msg) ->
    secondloc = msg.match[1]
    if secondloc == 'Pardot' || secondloc == 'the office' || secondloc == '950 East Paces Ferry Road, Atlanta, GA'
      msg.send "You're probably already here...(stare)"
      return
    else if secondloc == 'chatty' || secondloc == 'Chatty'
      msg.send "!one does not simply get to Chatty"
      return
    else if secondloc == 'alcohol' || secondloc == 'beer' || secondloc == 'drink' || secondloc == 'shot'
      msg.send "A couple seconds, depending on how close you are to the nearest fridge. (beer)"
      return

    firstloc = '950+East+Paces+Ferry+Road,Atlanta,GA'

    curdate = new Date()
    estimate_type = "best_guess"
    if curdate.getHours() > 14 && curdate.getHours() < 19
      estimate_type = "pessimistic"

    msg.http("https://maps.googleapis.com/maps/api/distancematrix/json")
       .query({origins: "#{firstloc}", destinations: "#{secondloc}", mode: "driving", departure_time: "now", key: 'AIzaSyB3YTBlgcu_Wupl0_ifRnM9zsaVR7uTPg4', traffic_model: "#{estimate_type}"})
       .header('Accept', 'application/json')
       .get() (err, res, body) ->
          if err
            msg.send "Error: #{err}"
          data = JSON.parse body
          if data.error_message
            msg.send "Error: #{data.error_message}"
          duration = if data?.rows[0]?.elements[0]?.duration_in_traffic then data?.rows[0]?.elements[0]?.duration_in_traffic?.text else data?.rows[0]?.elements[0]?.duration?.text
          if duration == null
            msg.send "Unable to retrieve travel time to #{secondloc}. (sadpanda)"
          else if typeof duration is 'undefined'
            msg.send "There is no driving route between #{secondloc} and the office. (sadpanda)"
          else
            msg.send "To get to #{data.destination_addresses[0]} from the office, it will take #{duration}. (drivinginmytruck)"
