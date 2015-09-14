db = require "./db"

class Builds
  add: (buildNumber, cb) ->
    conn = db.createClient()
    conn.query 'INSERT INTO builds (build_number, completed_at) VALUES (?, NOW())', [buildNumber], (err, r, f) ->
      conn.end()
      cb(err, r, f) if cb

  latest: (numBuilds, cb) ->
    conn = db.createClient()
    conn.query 'SELECT * FROM builds ORDER BY completed_at DESC LIMIT ?', [numBuilds], (err, r, f) ->
      conn.end()
      cb(err, r, f) if cb

module.exports =
  createClient: ->
    return new Builds()
