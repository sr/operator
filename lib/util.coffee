mysql = require "mysql"

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

