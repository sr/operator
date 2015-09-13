db = require "./db"

class Quotes
  constructor: (@conn) ->

  add: (quote, cb) ->
    @conn.query 'INSERT INTO quotes (quote) VALUES (?)', [quote], cb

  random: (n, substring, cb) ->
    if substring
      @conn.query 'SELECT quote FROM quotes WHERE quote LIKE ? ORDER BY rand() LIMIT ?', ["%" + substring + "%", n], (err, r, f) ->
        cb(err, r)
    else
      @conn.query 'SELECT quote FROM quotes ORDER BY rand() LIMIT ?', [n], (err, r, f) ->
        cb(err, r)

  delete: (quote, cb) ->
    @conn.query 'DELETE FROM quotes WHERE quote = ?', [quote], cb

module.exports =
  createClient: ->
    conn = db.createClient()
    return new Quotes(conn)
