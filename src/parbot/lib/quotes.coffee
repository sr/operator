db = require "./db"

class Quotes
  add: (context, quote, cb) ->
    db.createClient (conn) ->
      conn.query 'INSERT INTO quotes (context, quote) VALUES (?, ?)', [context, quote], (err, r, f) ->
        conn.end()
        cb(err, r, f) if cb

  random: (context, n, regexp, cb) ->
    db.createClient (conn) ->
      if regexp
        conn.query 'SELECT quote FROM quotes WHERE context = ? AND quote RLIKE ? ORDER BY rand() LIMIT ?', [context, ".*" + regexp + ".*", n], (err, r, f) ->
          conn.end()
          cb(err, r, f) if cb
      else
        conn.query 'SELECT quote FROM quotes WHERE context = ? ORDER BY rand() LIMIT ?', [context, n], (err, r, f) ->
          conn.end()
          cb(err, r, f) if cb

  delete: (context, quote, cb) ->
    db.createClient (conn) ->
      conn.query 'DELETE FROM quotes WHERE context = ? AND quote = ?', [context, quote], (err, r, f) ->
        conn.end()
        cb(err, r, f) if cb

module.exports =
  createClient: ->
    return new Quotes()
