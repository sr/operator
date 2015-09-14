db = require "./db"

class Quotes
  add: (quote, cb) ->
    conn = db.createClient()
    conn.query 'INSERT INTO quotes (quote) VALUES (?)', [quote], (err, r, f) ->
      conn.end()
      cb(err, r, f) if cb

  random: (n, substring, cb) ->
    conn = db.createClient()
    if substring
      conn.query 'SELECT quote FROM quotes WHERE quote LIKE ? ORDER BY rand() LIMIT ?', ["%" + substring + "%", n], (err, r, f) ->
        conn.end()
        cb(err, r, f) if cb
    else
      conn.query 'SELECT quote FROM quotes ORDER BY rand() LIMIT ?', [n], (err, r, f) ->
        conn.end()
        cb(err, r, f) if cb

  delete: (quote, cb) ->
    conn = db.createClient()
    conn.query 'DELETE FROM quotes WHERE quote = ?', [quote], (err, r, f) ->
      conn.end()
      cb(err, r, f) if cb

module.exports =
  createClient: ->
    return new Quotes()
