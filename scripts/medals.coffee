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

request = require('request')
moment = require('moment')
medals_api_url = 'http://www.medalbot.com/api/v1/medals'
medals = []
country = ''

module.exports = (robot) ->
  robot.respond /medals(?:\s+(.*))?$/i, (msg) ->

    if msg.match.length == 1 || msg.match[1] == null || msg.match[1] == '' || msg.match[1] == undefined
      country = ''
    else
      country = msg.match[1].toLowerCase()


    if country == '' || country == null
      country = ''
    else if country == 'usa' || country == 'united states' || country == 'america' || country == 'pardot' || country == 'salesforce'
      country = 'united-states'
    else if country == 'gb' || country == 'uk' || country == 'united kingdom' || country == 'great britain' || country == 'england' || country == 'wales' || country == 'scotland' || country == 'northern ireland'
      country = 'great-britain'
    else
      country = country.replace(/\s+/g, '-')

    getMedals (err)->
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
        total_medals = ''
        if medal_report.id == 'united-states'
          total_medals = '(murica) '
        else if medal_report.id == 'great-britain'
          total_medals = '(brexitchatty) '
        else
          total_medals = '(goldstar) '
        numPlace = ''
        if (medal_report.place % 10 == 1)
          numPlace = 'st'
        else if (medal_report.place % 10 == 2)
          numPlace = 'nd'
        else if (medal_report.place % 10 == 3)
          numPlace = 'rd'
        else
          numPlace = 'th'

        if medal_report.country_name != undefined && medal_report.country_name != 'undefined'
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
        return

getMedals = (callback) ->
  if country == '' || country == null
    request medals_api_url, (err, resp, body) ->
      medals = JSON.parse(body)
      callback()
  else
    request medals_api_url + '/' + country, (err, resp, body) ->
      medals = JSON.parse(body)
      callback()
