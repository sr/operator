# Description:
#   KPIBot commands
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   None
#

cronJob = require("cron").CronJob
utils   = require "../lib/util"

module.exports = (robot) ->
    # Record hours
    robot.hear /^!kpi\s+(\d+)$/i, (msg) ->
        console.log 'fooey'

        if !kpiBotEnabled then return
        hours = msg.match[1]

        if hours > 24
            msg.send "You cant work more than 24 hours in a day!"
        else



updateHours = (engineer, nickHours, date) ->
    hoursDate = getYesterday()
    
    if hoursDate == null
        return 'fail'
    
    #if date is not false and typeof date is not 'undefined'
    #    hoursDate = date
    
    if nickHours > 24
        nickHours = 8

# Get whatever 'yesterday' was
getYesterday = ->
    # Setup yesterdays date
    hoursDate = new Date()

    # If today is monday, record for friday
    if hoursDate.getDay() == 1
        hoursDate.setDate hoursDate.getDate() - 3
    else
        hoursDate.setDate hoursDate.getDate() - 1

    # Skip if its sat or sun
    if hoursDate.getDay() is 0 or hoursDate.getDay() is 7
        return null

    month = hoursDate.getMonth() + 1
    day   = hoursDate.getDate()
    year  = hoursDate.getFullYear()
 
    #month + '-' + day + '-' + year


# Is kpibot enabled for this bot?
kpiBotEnabled = () ->
    unless process.env.KPIBOT_ENABLED == 'true'
        false
    true

# Setup some crons to prompt us
new cronJob("00 45 9 * * 2-6", ->
  askForHours()
, null, true)

new cronJob("00 */10 10-12 * * 2-6", ->
  askForHours()
, null, true)

new cronJob("00 * * * * 2-6", ->
  client.send "NAMES", ircRoom
, null, true)



