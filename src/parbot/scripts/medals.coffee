# Description
#   A hubot script returning the medal standings or medal count from a country in the 2016 Summer Olympic Games, hosted by Rio de Janeiro, Brazil.
#
#
# Commands
#   hubot medals - returns the top 5 medal-winning nations
#   hubot medals (country) - returns the medal count of a specific country
#   hubot medals top (num) - returns as many of the top medal-winning nations as specified by num
#   hubot medals all - returns all medal-winning nations
#
# Author:
#   Akshay Easwaran <aeaswaran@salesforce.com>

moment = require('moment')
_ = require('underscore')
medals_api_url = 'http://www.medalbot.com/api/v1/medals'

module.exports = (robot) ->
  robot.respond /medals(?:\s+(?:(?:top\s+(\d+)\s*)|(all\s*)|(.*)))?$/, (msg) ->
    country = ''
    topCount = 5
    if msg.match[1]
      if msg.match[1] <= 0
        return
      else
        topCount = msg.match[1]
    else if msg.match[2]
      topCount = 100000 # this will automagically be converted to all medal-winning countries below
    else if msg.match[3]
      country = msg.match[3].toLowerCase().trim()
      country = cleanUpCountry(country)
      if country.indexOf('top-') != -1
        return

    getMedals(msg, country, (err, medals)->
      if err
        msg.send err
        return

      if medals.length > 0
        medals = _.chain(medals).sortBy((i) -> -i.bronze_count).sortBy((i) -> -i.silver_count).sortBy((i) -> -i.gold_count).sortBy((i) -> -i.total_count).value()

        i = 0
        date = moment().format('MMMM Do YYYY, h:mm:ss a')
        response = "<b>Medal Standings (as of #{date})</b><table><tr><th>Place</th><th>Country</th><th>Total</th><th>Gold</th><th>Silver</th><th>Bronze</th></tr>"
        if topCount > medals.length
          topCount = medals.length

        while i < topCount
          medal_report = medals[i]
          country_response = ''
          response += "<td>#{(i + 1)}</td><td>#{medal_report.country_name}"
          if medal_report.id == 'united-states'
            country_response = ' <img src="https://hipchat.dev.pardot.com/files/img/emoticons/1/murica-1447693257@2x.png" width="30" height="30">'
          else if medal_report.id == 'great-britain'
            country_response = ' <img src="https://hipchat.dev.pardot.com/files/img/emoticons/1/brexitchatty-1467219597@2x.png" width="30" height="30">'
          else
            country_response = ''
          response += "#{country_response}</td>"
          response += "<td>#{medal_report.total_count}</td>"
          response += "<td>#{medal_report.gold_count}</td>"
          response += "<td>#{medal_report.silver_count}</td>"
          response += "<td>#{medal_report.bronze_count}</td>"
          response += "</tr>"
          i++
        response += "</table>"
        msg.hipchatNotify(response, {color: "gray"})
      else
        medal_report = medals
        if medal_report.country_name != undefined && medal_report.country_name != 'undefined'
            total_medals = ''
            if medal_report.id == 'united-states'
              total_medals = '(murica) '
            else if medal_report.id == 'great-britain'
              total_medals = '(brexitchatty) '
            else
              total_medals = '(goldstar) '

            numPlace = suffixForNum(medal_report.place)

            if (medal_report.total_count > 1)
              total_medals = total_medals + "#{medal_report.country_name} is currently in #{medal_report.place}#{numPlace} with #{medal_report.total_count} medals: "
            else if (medal_report.total_count == 0)
              total_medals = total_medals + "#{medal_report.country_name} is currently in #{medal_report.place}#{numPlace} with 0 medals"
            else
              total_medals = total_medals + "#{medal_report.country_name} is currently in #{medal_report.place}#{numPlace} with 1 medal: "
            if medal_report.gold_count > 0
              if medal_report.gold_count == 0 || medal_report.gold_count > 1
                total_medals = total_medals + "#{medal_report.gold_count} gold medals"
              else
                total_medals = total_medals + 'a gold medal'

            if medal_report.silver_count > 0
              if medal_report.gold_count > 0 && medal_report.bronze_count == 0
                if medal_report.silver_count == 0 || medal_report.silver_count > 1
                  total_medals = total_medals + " and #{medal_report.silver_count} silver medals"
                else
                  total_medals = total_medals + ' and a silver medal'
              else if medal_report.gold_count > 0 && medal_report.bronze_count > 0
                if medal_report.silver_count == 0 || medal_report.silver_count > 1
                  total_medals = total_medals + ", #{medal_report.silver_count} silver medals"
                else
                  total_medals = total_medals + ', a silver medal'
              else
                if medal_report.silver_count == 0 || medal_report.silver_count > 1
                  total_medals = total_medals + " #{medal_report.silver_count} silver medals"
                else
                  total_medals = total_medals + ' a silver medal'

            if medal_report.bronze_count > 0
              if medal_report.gold_count > 0 && medal_report.silver_count > 0
                if medal_report.bronze_count == 0 || medal_report.bronze_count > 1
                  total_medals = total_medals + ", and #{medal_report.bronze_count} bronze medals"
                else
                  total_medals = total_medals + ', and a bronze medal'
              else if (medal_report.gold_count > 0 && medal_report.silver_count == 0) || (medal_report.silver_count > 0 && medal_report.gold_count == 0)
                if medal_report.bronze_count == 0 || medal_report.bronze_count > 1
                  total_medals = total_medals + " and #{medal_report.bronze_count} bronze medals"
                else
                  total_medals = total_medals + ' and a bronze medal'
              else
                if medal_report.bronze_count == 0 || medal_report.bronze_count > 1
                  total_medals = total_medals + " #{medal_report.bronze_count} bronze medals"
                else
                  total_medals = total_medals + ' a bronze medal'

            msg.send total_medals + '.'
        else
          msg.send "No medal results found for #{country}."
    )

getMedals = (msg, country, callback) ->
  url_combine = medals_api_url
  if country != ''
    url_combine += ('/' + country)

  msg.http(url_combine)
       .header('Content-Type', 'application/json')
       .get() (err, res, body) ->
          if err
            callback("Error: #{err}", JSON.parse(body))
          else
            callback(null, JSON.parse(body))

suffixForNum = (num) ->
  if (num % 100 > 10 && num % 100 < 20)
    return "th"
  else
    if (num % 10 == 1)
      return'st'
    else if (num % 10 == 2)
      return 'nd'
    else if (num % 10 == 3)
      return 'rd'
    else
      return 'th'

cleanUpCountry = (input) ->
  if input == ''
    return ''
  else if input == 'usa' || input == 'united states' || input == 'america' || input == 'pardot' || input == 'salesforce' || input == '\'murica' || input == 'murica' || input == 'america' || input == 'united states of america'
    return 'united-states'
  else if input == 'gb' || input == 'uk' || input == 'united kingdom' || input == 'great britain' || input == 'england' || input == 'wales' || input == 'scotland' || input == 'northern ireland' || input == 'britain'
    return 'great-britain'
  else
    return input.replace(/\s+/g, '-')
