db = require "./db"

class Deploys
  add: (syncMaster, buildNumber, cb) ->
    conn = db.createClient()
    conn.query 'INSERT INTO deploys (sync_master, build_number, started_at) VALUES (?, ?, NOW())', [syncMaster, buildNumber], (err, r, f) ->
      conn.end()
      cb(err, r, f) if cb

  latest: (numDeploys, cb) ->
    conn = db.createClient()
    conn.query 'SELECT * FROM deploys ORDER BY started_at DESC LIMIT ?', [numDeploys], (err, r, f) ->
      conn.end()
      cb(err, r, f) if cb

module.exports =
  createClient: ->
    return new Deploys()
