mysql = require "mysql"
parseDbUrl = require "parse-database-url"
dotenv = require "dotenv"

module.exports =
  createClient: ->
    dotenv.load(silent: true)
    mysql.createConnection(parseDbUrl(process.env.DATABASE_URL))
