mysql = require "mysql"
parseDbUrl = require "parse-database-url"
dotenv = require "dotenv"

module.exports =
  createClient: (cb) ->
    dotenv.load(silent: true)

    opts = parseDbUrl(process.env.DATABASE_URL)
    opts.timezone = 'Z'

    # for some reason, the timezone option is not sufficient
    client = mysql.createConnection(opts)
    client.query "SET time_zone='+00:00'", -> cb(client)
