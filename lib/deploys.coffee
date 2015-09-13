db = require "./db"

class Deploys
  constructor: (@conn) ->

  add: (syncMaster, buildNumber, cb) ->
    @conn.query 'INSERT INTO deploys (sync_master, build_number, started_at) VALUES (?, ?, NOW())', [syncMaster, buildNumber], cb

  latest: (numDeploys, cb) ->
    @conn.query 'SELECT * FROM deploys ORDER BY started_at DESC LIMIT ?', [numDeploys], (err, r, f) ->
      cb(err, r) if cb

module.exports =
  createClient: ->
    conn = db.createClient()
    return new Deploys(conn)
