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
    try
        connection = mysql.createConnection
            user: process.env.DB_USER,
            password: process.env.DB_PASSWORD,
            database: process.env.RELEASE_DATABASE,
            socketPath: '/var/run/mysqld/mysqld.sock'
        });

        connection
    catch e
        false

# Get connection to quote DB
module.exports.getQuoteDBConn = () ->
    try
        connection = mysql.createConnection
            user: process.env.DB_USER,
            password: process.env.DB_PASSWORD,
            database: process.env.QUOTE_DATABASE,
            socketPath: '/var/run/mysqld/mysqld.sock'
        });

        connection
    catch e
        false

# Get connection to hours DB
module.exports.getHoursDBConn = () ->
    try
        connection = mysql.createConnection
            user: process.env.DB_USER
            password: process.env.DB_PASSWORD
            database: process.env.HOURS_DATABASE
            socketPath: '/var/run/mysqld/mysqld.sock'

        connection
    catch e
        false        

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
            # console.log body
            account_info = JSON.parse(body)
            if account_info.error
                msg.send "Sorry, unable to fetch info for account ID: #{account_id}"
            else
                msg.send "Company: #{account_info.company} (#{account_info.id}) | Shard: #{account_info.shard_id}"

module.exports.apiGetAccountsLike = (search_text, msg) ->
    escaped_text = escape search_text
    options =
        url: "https://tools.pardot.com/accounts/like/#{escaped_text}"
        headers:
            api_key: '1b424ca119675c1c712957531498ac5af4646afb'

    request.get options, (error, response, body) ->
        if error
            console.log 'ERROR'
            console.log error.message
            msg.send "Sorry, unable to fetch accounts matching \'#{search_text}\'"
        else
            console.log body
            info_for_accounts = JSON.parse(body)
            if info_for_accounts.error
                msg.send "Sorry, unable to fetch accounts matching \'#{search_text}\'"
            else
                if info_for_accounts.length == 0
                    msg.send "No accounts found that matched \'#{search_text}\'"
                else
                    accounts_to_show = info_for_accounts.length
                    if accounts_to_show > 8
                        msg.send "#{accounts_to_show} accounts matched. Showing the first five."
                        accounts_to_show = 5

                    account_list = ''
                    for account, idx in info_for_accounts
                        if idx >= accounts_to_show
                            break
                        account_list = account_list + "Company: #{account.company} (#{account.id}) | Shard: #{account.shard_id}\n"

                    msg.send account_list
