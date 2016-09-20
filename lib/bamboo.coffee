httpClient = require "scoped-http-client"
_ = require 'underscore'

class Bamboo
  constructor: (@host, @username, @password) ->

  _buildHttpClient: () ->
    httpClient.create(@host)
      .timeout(15 * 1000)
      .auth(@username, @password)
      .header("accept", "application/json")

  # Returns an array of build keys+numbers which are 'in progress' for the given
  # build key
  #
  # Example:
  #     inProgressBuild('PDT-PPANT') => [{buildResultKey: 'PDT-PPANT-1234'}, {buildResultKey: 'PDT-PPANT-1235'}]
  inProgressBuilds: (buildKey, cb) ->
    @_buildHttpClient().path("/rest/api/latest/result/#{buildKey}?includeAllStates=true&buildstate=Unknown&max-results=100")
      .get() (err, res, body) ->
        if err?
          cb(err, null) if cb
        else if res.statusCode isnt 200
          cb(new Error("HTTP #{res.statusCode}"), null) if cb
        else
          results = _.chain(JSON.parse(body)?.results?.result || [])
            .select((r) -> r.lifeCycleState == "InProgress")
            .value()
          cb(null, results) if cb

  buildStatus: (buildResultKey, cb) ->
    @_buildHttpClient().path("/rest/api/latest/result/status/#{buildResultKey}")
      .get() (err, res, body) ->
        if err?
          cb(err, null) if cb
        else if res.statusCode isnt 200
          cb(new Error("HTTP #{res.statusCode}"), null) if cb
        else
          cb(null, JSON.parse(body)) if cb

module.exports = Bamboo
