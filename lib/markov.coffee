db = require './db'
markov = require 'markov'

class Markov
  @getSeed: (cb) ->
    db.createClient (conn) ->
      conn.query 'select quote from quotes', (err, rows, fields) ->
        seed = rows.map (r) -> r.quote.trim().replace(/<.*>/, '')
        cb(err, seed.join '\n') if cb

  seedMarkov: (order=3, cb) ->
    @markov = new markov order
    Markov.getSeed (err, seed) =>
      @markov.seed seed, () ->
        cb(err) if cb

  generate: (text, cb) ->
    # Use existing seeded markov chain if it exists
    return cb(null, @markov.respond(text).join(' ')) if @markov

    @seedMarkov 2, (err) =>
      return cb(err, null) if err
      cb(null, @markov.respond(text, 50).join(' '))

module.exports = exports = Markov
