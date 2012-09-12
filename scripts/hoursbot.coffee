# Description:
#   HoursBot commands
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
mysql   = require "mysql"

mysqlClient = mysql.createClient({
    user: process.env.QUOTE_DB_USER,
    password: process.env.QUOTE_DB_PASSWORD,
    database: process.env.QUOTE_DB_DATABASE
});

module.exports = (robot) ->
    # Record hours
    robot.hear /^!hours\s+(\d+)$/i, (msg) ->
        console.log 'fooey'

        if !hoursBotEnabled then return
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
    
    #db.open (err, db)
    ###
        if !err
            db.collection('hours', (err, collection)
                # Get everyone that sent in hours for this date
                collection.find({name: engineer, date : hoursDate}).toArray((err, items) {
                    if items.length == 0
                        collection.save({name: engineer, date : hoursDate, hours : nickHours});
                    else
                        existing = items[0];
                        existing.hours = nickHours;

                        # Resave
                        collection.save(existing);
                    
                    # Shut it down
                    db.close()
    
    #nickHours
    ###

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


# Is supportbot enabled for this bot?
hoursBotEnabled = () ->
    unless process.env.HOURSBOT_ENABLED == 'true'
        false
    true

