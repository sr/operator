# Description
#   A hubot script returning you the traffic time from the office to a given address or view current Atlanta traffic.
# Commands
#   hubot traffic - returns image of current traffic conditions in Atlanta
#   hubot traveltime <location> - returns current travel time to the provided location from the office
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
        severity: "3,4",
        output: 'json',  
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
              if incident.verified and incident.description
                if incident?.point?.coordinates
                  lat = incident.point.coordinates[0]
                  lon = incident.point.coordinates[1]
                  url = "https://www.google.com/maps/place/#{lat},#{lon}/data=!5m1!1e1"
         
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
                lane = if incident.lane is not "" then incident.lane else null
                
                description = incident.description
                description += " (#{type}"
                if lane
                  description += ", Lane: #{lane}"
                if incident.roadClosed
                  description += ", Road is closed"
                description += ")"           

                if url
                  incidentStr += "<a name=\"Google Maps Traffic Report\" href=\"#{url}\">#{description}</a><br>" 
                else 
                  incidentStr += "#{description}\n"

          if incidentStr is not ''
            msg.hipchatNotify("#{incidentStr}<img src=#{imageUrl}>", {
              notify: false,
              color: "red"
            })
          else 
            html = "<a>No major traffic incidents in Atlanta! <\a><img src="https://hipchat.dev.pardot.com/files/img/emoticons/1/buttrock-1423164525.gif"><br><img src=#{imageUrl}>"
            msg.hipchatNotify("#{html}", {
              notify: false,
              color: "green"
            })
        else
          msg.send "#{imageUrl}"

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
