# Description
#   A hubot script returning you the traffic time from the office to a given address or view current Atlanta traffic.
# Commands
#   hubot traffic (map|incidents) - returns current traffic conditions in Atlanta
#   hubot traveltime (at <departure_time>) (to) <location> - returns travel time to location from the office, default departure time is now
# Author:
#   Akshay Easwaran <aeaswaran@salesforce.com>
#

moment = require('moment')

module.exports = (robot) ->
  robot.respond /traffic(?:\s+(map|incidents))?\s*$/i, (msg) ->

    # determines if it should just show the map or just show the incidents
    # default is to show both
    mode = msg.match[1] ? ''

    bingkey = "AlyNrLtoFkBueO0BAhC05RMpMHjo4SjsenGNPvFTbhfsUqFLmArnl32AEiy_tP_r"

    # traffice image
    imageUrl = "http://dev.virtualearth.net/REST/V1/Imagery/Map/Road/33.7490%2C%20-84.3880/9?mapSize=400,400&mapLayer=TrafficFlow&format=png&key=#{bingkey}"
    if mode is 'map'
      html = "<img src=\"#{imageUrl}\">"
      msg.hipchatNotify("#{html}", {
        notify: false,
        color: "yellow"
      })
      return
    
    # traffic descriptions
    url = "http://dev.virtualearth.net/REST/v1/Traffic/Incidents/33.45,-84.70,34.11,-83.91"
    msg.http(url)
      .query({
        severity: "2,3,4",
        key: "#{bingkey}"})
      .get() (err, res, body) ->
        if err
          msg.send "#{imageUrl}"
          return
        data = JSON.parse body
        if data?.resourceSets[0]?.resources?
          incidents = data.resourceSets[0].resources
          incidentStr = ''
          for i in [0..incidents.length - 1]
            incidentStr += getIncidentDescription(incidents[i]) 

          msg.send JSON.stringify data

          html = ''
          if incidentStr isnt ''
            html = "#{incidentStr}"
            color = 'red'
          else
            html = "No major traffic incidents in Atlanta! <img src=\"https://hipchat.dev.pardot.com/files/img/emoticons/1/buttrock-1423164525.gif\">"
            color = 'green'
          if mode isnt 'incidents'
            html += "<br><img src=\"#{imageUrl}\">"

          msg.hipchatNotify("#{html}", {
            notify: false,
            color: "#{color}"
          })

        else
          html = "<img src=\"#{imageUrl}\">"
          msg.hipchatNotify("#{html}", {
            notify: false,
            color: "yellow"
          })

  getIncidentDescription = (incident) ->
    # check all requirements for this method
    if not incident or 
       not incident.verified or 
       not incident.description or
       incident.description == ""
      return ''

    type = switch incident.type
      when 1 then "Accident"
      when 2 then "Congestion"
      when 3 then "Disabled Vehicle"
      when 4 then "Mass Transit"
      when 5 then "Miscellaneous"
      when 6 then "Other News"
      when 7 then "Planned Event"
      when 8 then "Road Hazard"
      when 9 then "Construction"
      when 10 then "Alert"
      when 11 then "Weather"
      else "Unknown"
                    
    description = incident.description
    
    # add extra info in parentheses
    search = description.search "#{type}"
    info = if search == -1 then "#{type}" else ''
    if incident.lane and incident.lane != "" 
      info += if info == '' then "Lane: #{incident.lane}" else ", Lane: #{incident.lane}"
    if incident.roadClosed
      info += if info == '' then "Road is closed" else ", Road is closed"
    description += if info != '' then " (#{info})" else '' 
    
    # link to a google maps traffic view if available
    if incident?.point?.coordinates
      lat = incident.point.coordinates[0]
      lon = incident.point.coordinates[1]
      url = "https://www.google.com/maps/place/#{lat},#{lon}/data=!5m1!1e1"
      return "<a title=\"Google Maps Traffic Overview\" href=\"#{url}\">#{description}</a><br>" 
    else 
      return "#{description}<br>"


  robot.respond /traveltime(?:\s+at\s*(?:the\s*)?(\d{1,2}|sol|c|speed\s*of\s*light|warp\s*speed)(?::(\d{2}))?(pm|am)?)?(?:\s*to)?\s+(.*)$/i, (msg) ->
    if not msg.match[4]
      return

    secondloc = msg.match[4]

    if secondloc == 'Pardot' || secondloc == 'the office' || secondloc == '950 East Paces Ferry Road, Atlanta, GA'
      msg.send "You're probably already here...(stare)"
      return
    else if secondloc == 'chatty' || secondloc == 'Chatty'
      msg.send "!one does not simply get to Chatty"
      return
    else if secondloc == 'alcohol' || secondloc == 'beer' || secondloc == 'drink' || secondloc == 'shot'
      msg.send "A couple seconds, depending on how close you are to the nearest fridge. (beer)"
      return

    sol  = msg.match[1] and isNaN(msg.match[1])
    hour = if not sol and msg.match[1] then msg.match[1]
    min  = msg.match[2]
    ampm = if msg.match[3] then msg.match[3] else 'pm'

    curdate = new Date()
    depdate = new Date()
    if hour
      hour = (hour % 12) + (if ampm is 'pm' then 12 else 0)
      min  = if min then min % 60 else 0
      depdate.setHours(hour)
      depdate.setMinutes(min)

    if depdate > curdate
      departure = depdate.getTime()
      departurereply = moment(depdate).format("h:mm A")
    else
      departure = curdate.getTime()

    firstloc = '950+East+Paces+Ferry+Road,Atlanta,GA'

    msg.http("https://maps.googleapis.com/maps/api/distancematrix/json")
       .query({
          origins: "#{firstloc}",
          destinations: "#{secondloc}",
          mode: 'driving',
          departure_time: "#{departure}",
          key: 'AIzaSyB3YTBlgcu_Wupl0_ifRnM9zsaVR7uTPg4',
          traffic_model: 'best_guess'})
       .header('Accept', 'application/json')
       .get() (err, res, body) ->
          if err
            msg.send "Error: #{err}"
            return

          data = JSON.parse body
          if data.error_message
            msg.send "Error: #{data.error_message}"
            return

          disttext = data?.rows[0]?.elements[0]?.distance?.text
          distance = data?.rows[0]?.elements[0]?.distance?.value

          if data?.rows[0]?.elements[0]?.duration_in_traffic
            # get duration in traffic if available
            duration = data?.rows[0]?.elements[0]?.duration_in_traffic?.text
          else
            duration = data?.rows[0]?.elements[0]?.duration?.text

          if sol and typeof duration isnt 'undefined'
            solconst = 299792458
            # calculate time from speed of light
            duration = distance / solconst
            duration = "#{duration}".substring(0,7)

          if duration == null
            msg.send "Unable to retrieve travel time to #{secondloc}. (sadpanda)"
          else if typeof duration is 'undefined'
            msg.send "There is no #{if sol then '(lightning)' else 'driving'} route between #{secondloc} and the office. (sadpanda)"
          else
            # create google maps direction url
            start = data.origin_addresses[0].replace(/\s/g, '+')
            end = data.destination_addresses[0].replace(/\s/g, '+')
            dirurl = "https://www.google.com/maps/dir/#{start}/#{end}"

            # build up reply message
            reply = 'To get to '

            reply += "<a name=\"Google Maps Directions\" href=\"#{dirurl}\">"
            reply += "#{data.destination_addresses[0]} from the office"
            reply += "</a>"

            if sol
              reply += " (#{disttext}) at the speed of light "
              reply += "<img src=\"https://hipchat.dev.pardot.com/files/img/emoticons/1/fastparrot-1462906216.gif\">"
              reply += " it will take #{duration} seconds. "
              reply += "<img src=\"https://hipchat.dev.pardot.com/files/img/emoticons/1/lightning-1448383433.png\">"
            else
              reply += if departurereply then ", leaving at #{departurereply}" else ''
              reply += ", it will take #{duration}. "
              reply += "<img src=\"https://hipchat.dev.pardot.com/files/img/emoticons/1/drivinginmytruck-1452626743.png\">"

            msg.hipchatNotify("#{reply}", {
              notify: false,
              color: "yellow"
            })

