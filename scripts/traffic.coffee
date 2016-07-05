# Description
#   A hubot script returning you the traffic time from the office to a given address or view current Atlanta traffic.
# Commands
#   hubot traffic - returns image of current traffic conditions in Atlanta
#   hubot traveltime (at <departure_time>) (to) <location> - returns travel time to location from the office, default departure time is now
# Author:
#   Akshay Easwaran <aeaswaran@salesforce.com>
#

module.exports = (robot) ->
  robot.respond /traffic$/i, (msg) ->
    bingkey = "AlyNrLtoFkBueO0BAhC05RMpMHjo4SjsenGNPvFTbhfsUqFLmArnl32AEiy_tP_r"
    
    # traffice image
    imageUrl = "http://dev.virtualearth.net/REST/V1/Imagery/Map/Road/33.7490%2C%20-84.3880/9?mapSize=400,400&mapLayer=TrafficFlow&format=png&key=#{bingkey}"
    
    # traffic descriptions
    url  = "http://dev.virtualearth.net/REST/v1/Traffic/Incidents/33.5,-84.6,34.15,-84.1"
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
            if incidents[i]
              incident = incidents[i]
              if incident.verified && description != "" 
                type = switch
                         when incident.type is 1 then "Accident"
                         when incident.type is 2 then "Congestion"
                         when incident.type is 3 then "Disabled Vehicle"
                         when incident.type is 4 then "Mass Transit"
                         when incident.type is 5 then "Miscellaneous"
                         when incident.type is 6 then "Other News"
                         when incident.type is 7 then "Planned Event"
                         when incident.type is 8 then "Road Hazard"
                         when incident.type is 9 then "Construction"
                         when incident.type is 10 then "Alert"
                         when incident.type is 11 then "Weather"
                         else "Unknown"
                
                lane = if incident.lane is not "" then incident.lane else null
                
                description = incident.description
                description += " (#{type}"
                if lane
                  description += ", Lane: #{lane}"
                if incident.roadClosed
                  description += ", Road is closed"
                description += ")"           

                if incident?.point?.coordinates
                  lat = incident.point.coordinates[0]
                  lon = incident.point.coordinates[1]
                  url = "https://www.google.com/maps/place/#{lat},#{lon}/data=!5m1!1e1"
                  incidentStr += "<a name=\"Google Maps Traffic Report\" href=\"#{url}\">#{description}</a><br>" 
                else 
                  incidentStr += "#{description}<br>"

          if incidentStr != ''
            msg.hipchatNotify("#{incidentStr}<img src=\"#{imageUrl}\">", {
              notify: false,
              color: "red"
            })
          else 
            html = "No major traffic incidents in Atlanta! <img src=\"https://hipchat.dev.pardot.com/files/img/emoticons/1/buttrock-1423164525.gif\"><br><img src=\"#{imageUrl}\">"
            msg.hipchatNotify("#{html}", {
              notify: false,
              color: "green"
            })
        else
          msg.send "#{imageUrl}"

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
      departurereply = depdate.toLocaleTimeString('en-US',
        {hour: 'numeric', minute: 'numeric'})
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

