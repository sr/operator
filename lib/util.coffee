mysql = require "mysql"

request = require 'request'

# Get all nicknames from the robot
module.exports.getAllNicks = (robot) ->
    (v.name for k,v of robot.users())

# Find an engineer based on nickname
module.exports.findEngineer = (nickname) ->
    engineers = [
        { name: "berg", list: ["berg"] },
        { name: "evinti", list : ["evinti"] },
        { name: "ian", list : ["ian"] },
        { name: "jarrett", list : ["jarrett", "jart"] },
        { name: "meredith", list : ["meredith"] },
        { name: "reid", list : ["reid"] },
        { name: "stokes", list : ["stokes"] },
        { name: "wino", list : ["wino"] },
        { name: "steviep", list : ["steviep", "stephen", "stephen_laptop"] }
    ]

    for engineer in engineers
        for nick in engineer.list
             if nickname.match(/^nick/) is not null
                return engineer.name

    false

# Get connection to release DB
module.exports.getReleaseDBConn = () ->
    mysqlClient = mysql.createClient({
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: process.env.RELEASE_DATABASE
    });

    mysqlClient

# Get connection to quote DB
module.exports.getQuoteDBConn = () ->
    mysqlClient = mysql.createClient({
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: process.env.QUOTE_DATABASE
    });

    mysqlClient

# Get connection to hours DB
module.exports.getHoursDBConn = () ->
    mysqlClient = mysql.createClient({
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: process.env.HOURS_DATABASE
    });

    mysqlClient

# Get account information from internal API
module.exports.apiGetAccountInfo = (account_id, msg) ->
    options =
    url: "https://tools.pardot.com/accounts/#{account_id}"
    headers:
        api_key: '1b424ca119675c1c712957531498ac5af4646afb'

    request.get options, (error, response, body) ->
        if error
            console.log 'ERROR'
            console.log error.message
            msg.send "Sorry, unable to fetch info for account ID: #{account_id}"
        else
            console.log body
            account_info = JSON.parse(body)
            if account_info.error
                msg.send "Sorry, unable to fetch info for account ID: #{account_id}"
            else
                msg.send 'Company: ' + account_info.company + ' (' + account_info.id + ') | Found on Shard: ' + account_info.shard_id
