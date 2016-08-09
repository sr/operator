# Description
#   A hubot script returning the medal standings or medal count from a country in the 2016 Summer Olympic Games, hosted by Rio de Janeiro, Brazil.
#
#
# Commands
#   hubot medals - returns the top 3 medal-winning nations
#   hubot medals (country) - returns the medal count of a specific country
#
# Author:
#   Akshay Easwaran <aeaswaran@salesforce.com>

moment = require('moment')
medals_api_url = 'http://www.medalbot.com/api/v1/medals'

module.exports = (robot) ->
  robot.respond /medals(?:\s+(.*))?$/i, (msg) ->
    country = ''
    if !(msg.match.length == 1 || msg.match[1] == null || msg.match[1] == '' || msg.match[1] == undefined)
      country = msg.match[1].toLowerCase()

    country = cleanUpCountry(country)

    getMedals(msg, country, (err, medals)->
      if err
        msg.send err
        return

      if medals.length > 0
        i = 0
        date = moment().format('MMMM Do YYYY, h:mm:ss a')
        medal_response = "Medal Standings (as of #{date})\n"
        while i < 3
          medal_report = medals[i]
          country_response = ''
          if medal_report.id == 'united-states'
            country_response = '(murica) '
          else if medal_report.id == 'great-britain'
            country_response = '(brexitchatty) '
          else
            country_response = ''
          country_response = country_response + medal_report.country_name
          medal_response = medal_response + "#{medal_report.place}) #{country_response} (#{medal_report.total_count} total - #{medal_report.gold_count} gold, #{medal_report.silver_count} silver, #{medal_report.bronze_count} bronze)\n"
          i++
        msg.send medal_response
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
    url_combine = url_combine + '/' + country

  msg.http(url_combine)
       .header('Content-Type', 'application/json')
       .get() (err, res, body) ->
          if err
            callback("Error: #{err}", JSON.parse(body))
          else
            callback(null, JSON.parse(body))

suffixForNum = (num) ->
  if (num > 10 && num < 20)
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
