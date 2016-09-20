httpClient = require "scoped-http-client"

class Canoe
  constructor: (@host, @api_token) ->

  _buildClient: () ->
    httpClient.create(@host)
      .timeout(15 * 1000)
      .query("api_token", @api_token)
      .header("accept", "application/json")

  deploys: (target_name, repo_name, cb) ->
    @_buildClient().path("/api/targets/#{target_name}/projects/#{repo_name}/deploys")
      .get() (err, res, body) ->
        if err?
          cb(err, null) if cb
        else if res.statusCode isnt 200
          cb(new Error("HTTP #{res.statusCode}"), null) if cb
        else
          cb(null, JSON.parse(body)) if cb

  builds: (repo_name, branch_name, limit, cb) ->
    @_buildClient().path("/api/projects/#{repo_name}/branches/#{branch_name}/builds")
      .query("limit", limit)
      .get() (err, res, body) ->
        if err?
          cb(err, null) if cb
        else if res.statusCode isnt 200
          cb(new Error("HTTP #{res.statusCode}"), null) if cb
        else
          cb(null, JSON.parse(body)) if cb

module.exports = Canoe
