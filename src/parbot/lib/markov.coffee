Promise = require 'bluebird'
db = require './db'
markov = require 'markov'

class Markov
  @getSeed: () ->
    new Promise (resolve, reject) ->
      db.createClient (conn) ->
        conn.query 'select quote from quotes', (err, rows, fields) ->
          return reject(err) if err

          seed = rows.map (r) -> r.quote.trim().replace(/<.*>/, '')
          resolve(seed.join ' ')

  getSeededMarkov: () ->
    # Resolve cached markov object if it exists
    return Promise.resolve(@markov) if @markov

    # Otherwise create a new markov object
    new Promise (resolve, reject) =>
      Markov.getSeed().then (seed) =>
        @markov = markov(4)
        @markov.seed seed, () => resolve(@markov)
      .catch () -> throw new Error 'Fail to seed Markov object'

  reseed: () ->
    @markov = null

  generateResponse: (text) ->
    @getSeededMarkov().then (m) ->
      m.respond(text, 50).join(' ')
    .catch () -> 'An error has occured (sadpanda)'


module.exports = exports = Markov
