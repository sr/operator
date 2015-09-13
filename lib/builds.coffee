db = require "./db"

class Builds
  constructor: (@conn) ->

  add: (buildNumber, cb) ->
    @conn.query 'INSERT INTO builds (build_number, completed_at) VALUES (?, NOW())', [buildNumber], cb

  latest: (numBuilds, cb) ->
    @conn.query 'SELECT * FROM builds ORDER BY completed_at DESC LIMIT ?', [numBuilds], (err, r, f) ->
      cb(err, r) if cb

module.exports =
  createClient: ->
    conn = db.createClient()
    return new Builds(conn)
