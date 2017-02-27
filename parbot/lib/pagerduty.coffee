httpClient = require "scoped-http-client"

class PagerDuty
  constructor: (@subdomain, @api_key) ->

  _buildClient: () ->
    httpClient.create("https://#{@subdomain}.pagerduty.com")
      .timeout(15 * 1000)
      .header("Authorization", "Token token=#{@api_key}")
      .header("Content-Type", "application/json")
      .header("Accept", "application/json")

  schedules: (cb = null) ->
    @_buildClient().path("/api/v1/schedules")
      .get() (err, res, body) ->
        if err?
          cb(err, null) if cb
        else
          json = JSON.parse(body)
          if json.error?
            cb(json.error.message, null) if cb
          else
            cb(null, json.schedules) if cb

  schedule: (id, query = {}, cb = null) ->
    @_buildClient().path("/api/v1/schedules/#{id}")
      .query(query)
      .get() (err, res, body) ->
        if err?
          cb(err, null) if cb
        else
          json = JSON.parse(body)
          if json.error?
            cb(json.error.message, null) if cb
          else
            cb(null, json.schedule) if cb

  scheduleEntries: (id, query = {}, cb = null) ->
    @_buildClient().path("/api/v1/schedules/#{id}/entries")
      .query(query)
      .get() (err, res, body) ->
        if err?
          cb(err, null) if cb
        else
          json = JSON.parse(body)
          if json.error?
            cb(json.error.message, null) if cb
          else
            cb(null, json.entries) if cb

  escalationPolicies: (query = {}, cb = null) ->
    @_buildClient().path("/api/v1/escalation_policies")
      .query(query)
      .get() (err, res, body) ->
        if err?
          cb(err, null) if cb
        else
          json = JSON.parse(body)
          if json.error?
            cb(json.error.message, null) if cb
          else
            cb(null, json.escalation_policies) if cb

  incidents: (query = {}, cb = null) ->
    @_buildClient().path("/api/v1/incidents")
      .query(query)
      .get() (err, res, body) ->
        if err?
          cb(err, null) if cb
        else
          json = JSON.parse(body)
          if json.error?
            cb(json.error.message, null) if cb
          else
            cb(null, json.incidents) if cb

  trigger: (serviceKey, description, cb) ->
    eventClient = httpClient.create("https://events.pagerduty.com")
      .header("Content-Type", "application/json")
      .header("Accept", "application/json")

    eventClient.path("/generic/2010-04-15/create_event.json")
      .post(JSON.stringify(service_key: serviceKey, event_type: "trigger", description: description)) (err, res, body) ->
        if err?
          cb(err, null) if cb
        else
          json = JSON.parse(body)
          if json.error?
            cb(json.error.message, null) if cb
          else
            cb(null, json) if cb

  users: (query = {}, cb = null) ->
    @_buildClient().path("/api/v1/users")
      .query(query)
      .get() (err, res, body) ->
        if err?
          cb(err, null) if cb
        else
          json = JSON.parse(body)
          if json.error?
            cb(json.error.message, null) if cb
          else
            cb(null, json.users) if cb

  updateIncidents: (incidents, requester_id, cb = null) ->
    @_buildClient().path("/api/v1/incidents")
      .put(JSON.stringify(incidents: incidents, requester_id: requester_id)) (err, res, body) ->
        if err?
          cb(err, null) if cb
        else
          json = JSON.parse(body)
          if json.error?
            cb(json.error.message, null) if cb
          else
            cb(null, json.incidents) if cb

  createOverride: (scheduleId, userId, start, end, cb = null) ->
    override = {user_id: userId, start: start.toISOString(), end: end.toISOString()}
    @_buildClient().path("/api/v1/schedules/#{scheduleId}/overrides")
      .post(JSON.stringify(override: override)) (err, res, body) ->
        if err?
          cb(err, null) if cb
        else
          json = JSON.parse(body)
          if json.error?
            cb(json.error.message, null) if cb
          else
            cb(null, json.override) if cb

module.exports = PagerDuty
