# Description:
#   Commands related to finding Pardot accounts by name and ID.
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_PAGERDUTY_API_KEY
#   HUBOT_PAGERDUTY_SUBDOMAIN
#   HUBOT_PAGERDUTY_SERVICES
#   HUBOT_PAGERDUTY_USER_ID
#   HUBOT_PAGERDUTY_SERVICE_API_KEY
#
# Commands:
#   hubot oncall - Returns who is on-call for the various schedules
#   hubot pager sup - Returns information about unresolved pages
#   hubot pager ack - Acknowledges all incidents assigned to you
#   hubot pager ack <number> [number...] - Acknowledges the specified incidents
#   hubot pager override <schedule> <duration> - Creates an ad-hoc schedule override
#   hubot pager resolve - Resolves all incidents assigned to you
#   hubot pager resolve <number> [number...] - Resolves the specified incidents
#   hubot pager policies - Returns a list of escalation policies
#   hubot pager trigger "<policy>" <message> - Triggers a page, assigned to the specified escalation policy
#   hubot pager trigger "<name>" <message> - Triggers a page, assigned to the specified person
#
# Author:
#   alindeman

_ = require "underscore"
async = require "async"
moment = require "moment-timezone"
shellquote = require "../lib/shellquote"
PagerDuty = require "../lib/pagerduty"
HumanDuration = require "../lib/human_duration"

module.exports = (robot) ->
  return unless process.env.HUBOT_PAGERDUTY_API_KEY? and process.env.HUBOT_PAGERDUTY_SUBDOMAIN?
  pagerduty = new PagerDuty(process.env.HUBOT_PAGERDUTY_SUBDOMAIN, process.env.HUBOT_PAGERDUTY_API_KEY)

  withSchedulesAndOnCallUsers = (cb) ->
    pagerduty.schedules (err, schedules) ->
      if err?
        msg.reply "Something went wrong: #{err}"
      else
        now = moment().format()
        oneHour = moment().add(1, 'hours').format()

        schedules = schedules.sort((a, b) -> a.name.localeCompare(b.name))
        async.mapLimit schedules, 3,
          (schedule, cb) ->
            pagerduty.scheduleEntries schedule.id, {since: now, until: oneHour, overflow: "true"}, (err, entries) ->
              schedule.on_call_user = entries[0].user if entries.length > 0
              cb(err, schedule)
          (err, detailedSchedules) ->
            cb(err, detailedSchedules)

  incidentSummary = (incident) ->
    if incident.trigger_summary_data
      if incident.trigger_summary_data.pd_nagios_object == 'service'
        "#{incident.trigger_summary_data.HOSTNAME}/#{incident.trigger_summary_data.SERVICEDESC}"
      else if incident.trigger_summary_data.pd_nagios_object == 'host'
        "#{incident.trigger_summary_data.HOSTNAME}/#{incident.trigger_summary_data.HOSTSTATE}"
      # email services
      else if incident.trigger_summary_data.subject
        incident.trigger_summary_data.subject
      else if incident.trigger_summary_data.description
        incident.trigger_summary_data.description
      else
        ""
    else
      ""

  userSummary = (user) ->
    if user?
      "<a href=\"mailto:#{user.email}\">#{user.name}</a>"
    else
      ""

  incidentTable = (incidents) ->
    response = "<table><tr><th>ID</th><th>Summary</th><th>Assigned To</th></tr>"
    for incident in incidents
      userSummaries = _.map(incident.assigned_to, (a) -> userSummary(a.object)).join(", ")
      response += "<tr>"
      response += "<td><a href=\"#{incident.html_url}\">#{incident.incident_number}</a></td>"
      response += "<td>#{incidentSummary(incident)}</td>"
      response += "<td>#{userSummaries}</td>"
      response += "</tr>"
    response += "</table>"
    response

  withPagerDutyUserId = (userEmailAddress, cb) ->
    if userEmailAddress
      pagerduty.users {query: userEmailAddress}, (err, users) ->
        if err? || users?.length == 0
          cb("no PagerDuty user found with email '#{userEmailAddress}'") if cb
        else
          cb(null, users[0].id) if cb
    else
      cb("no email address provided, can't lookup PagerDuty user by email address") if cb

  withPagerDutyUserIdOrDefault = (userEmailAddress, cb) ->
    returnDefault = ->
      if process.env.HUBOT_PAGERDUTY_USER_ID
        cb(null, process.env.HUBOT_PAGERDUTY_USER_ID) if cb
      else
        cb("Could not find PagerDuty user for '#{userEmailAddress}'", null) if cb

    if userEmailAddress
      pagerduty.users {query: userEmailAddress}, (err, users) ->
        if err? || users?.length == 0
          returnDefault()
        else
          cb(null, users[0].id) if cb
    else
      returnDefault()

  updateIncidents = (options, cb = null) ->
    query = options.query || {}
    filterFn = options.filter || (() -> true)
    parameters = options.parameters || {}
    requesterId = options.requesterId

    pagerduty.incidents query, (err, incidents) ->
      if err?
        cb(err) if cb
      else
        incidents = _.filter(incidents, filterFn)
        if incidents.length == 0
          cb("Could not find any matching incidents", null) if cb
        else
          incidents = _.chain(incidents)
            .map((incident) -> _.extend({id: incident.id}, parameters))
            .value()
          pagerduty.updateIncidents incidents, requesterId, cb

  scheduleOverride = (scheduleId, userId, durationMs, cb = null) ->
    now = Date.now()
    start = new Date(now)
    end = new Date(now + durationMs)

    pagerduty.createOverride scheduleId, userId, start, end, cb

  isPrefixMatch = (prefix, test) -> test.length >= prefix.length && prefix == test[0...prefix.length]
  isSuffixMatch = (suffix, test) -> test.length >= suffix.length && suffix == test[-suffix.length..-1]

  isReasonableMatch = (input, test) ->
    input = input.replace(/[^a-zA-Z0-9]+/g, "").toLocaleLowerCase()
    test = test.replace(/[^a-zA-Z0-9]+/g, "").toLocaleLowerCase()
    input.length >= 3 && test.length >= 3 && (isPrefixMatch(input, test) || isSuffixMatch(input, test))

  withBestGuessForSchedule = (input, cb) ->
    pagerduty.schedules (err, schedules) ->
      if err?
        cb(err) if cb
      else
        schedules = schedules.sort((a, b) -> a.name.localeCompare(b.name))
        for schedule in schedules
          if isReasonableMatch(input, schedule.name)
            cb(null, schedule) if cb
            return

        cb(null, null) if cb # nothing found that is a reasonable match

  withBestGuessForEscalationPolicyOrUser = (input, cb) ->
    if input[0] == "@"
      mentionName = input[1..-1].toLocaleLowerCase()
      users = robot.brain.users()
      if userId = _.findKey(users, (user) -> user.mention_name?.toLocaleLowerCase() == mentionName)
        user = robot.brain.userForId(userId)
        pagerduty.users {query: user.email_address}, (err, users) ->
          if err? || users.length == 0
            cb(err, null)
          else
            cb(err, user: users[0])
      else
        cb(null, null)
    else
      pagerduty.escalationPolicies {limit: 100}, (err, policies) ->
        if err?
          cb(err, null)
        else
          policies = policies.sort((a, b) -> a.name.localeCompare(b.name))
          for policy in policies
            if isReasonableMatch(input, policy.name)
              cb(null, policy: policy)
              return

          pagerduty.users {limit: 100}, (err, users) ->
            if err
              cb(err, null)
            else
              users = users.sort((a, b) -> a.name.localeCompare(b.name))
              for user in users
                if isReasonableMatch(input, user.name)
                  cb(null, user: user)
                  return

              cb(null, null) # nothing found that's a reasonable match

  robot.respond /oncall$/i, (msg) ->
    withSchedulesAndOnCallUsers (err, schedules) ->
      if err?
        msg.reply "Something went wrong: #{err}"
      else
        response = "<table><tr><th>Schedule</th><th>On-Call</th>"
        for schedule in schedules
          response += "<tr>"
          response += "<td>#{schedule.name}</td>"
          response += "<td>#{schedule.on_call_user?.name}</td>"
          response += "</tr>"
        response += "</table>"
        msg.hipchatNotify(response)

  robot.respond /pager\s+(?:sup|inc|incidents|problems|status)$/i, (msg) ->
    pagerduty.incidents {status: "triggered,acknowledged", sort_by: "incident_number:desc"}, (err, incidents) ->
      if err?
        msg.reply "Something went wrong: #{err}"
      else
        if incidents.length > 0
          groupedIncidents = _.groupBy(incidents, "status")
          async.series [
            (cb) ->
              if groupedIncidents.triggered?.length > 0
                msg.hipchatNotify "<strong>Triggered</strong>#{incidentTable(groupedIncidents.triggered)}", {color: "red"}, cb
              else
                cb(null)
            (cb) ->
              if groupedIncidents.acknowledged?.length > 0
                msg.hipchatNotify "<strong>Acknowledged</strong>#{incidentTable(groupedIncidents.acknowledged)}", {color: "yellow"}, cb
              else
                cb(null)
          ], (err) ->
            if err?
              msg.send "Something went wrong: #{err}"
        else
          msg.send "No open incidents 🎉"

  robot.respond /pager\s+(?:ack(?:nowledge)?)$/i, (msg) ->
    withPagerDutyUserIdOrDefault msg.message.user.email_address, (err, userId) ->
      if err?
        msg.reply "Something went wrong: #{err}"
      else
        updateIncidents {
          query: {status: "triggered", assigned_to_user: userId},
          parameters: {status: "acknowledged"},
          requesterId: userId,
        }, (err, incidents) ->
          if err?
            msg.reply "Something went wrong: #{err}"
          else
            msg.reply "Incidents #{_.map(incidents, "incident_number").join(", ")} acknowledged"

  robot.respond /pager\s+(?:ack(?:nowledge)?)\s+((?:\d+\s*)+)$/i, (msg) ->
    ids = msg.match[1].split(/\s+/)
    withPagerDutyUserIdOrDefault msg.message.user.email_address, (err, userId) ->
      if err?
        msg.reply "Something went wrong: #{err}"
      else
        filterFn = (incident) -> _.contains(ids, incident.incident_number.toString())
        updateIncidents {
          query: {status: "triggered"},
          filter: filterFn,
          parameters: {status: "acknowledged"},
          requesterId: userId,
        }, (err) ->
          if err?
            msg.reply "Something went wrong: #{err}"
          else
            msg.reply "Incidents #{ids.join(", ")} acknowledged"

  robot.respond /pager\s+(?:res(?:olve)?)$/i, (msg) ->
    withPagerDutyUserIdOrDefault msg.message.user.email_address, (err, userId) ->
      if err?
        msg.reply "Something went wrong: #{err}"
      else
        updateIncidents {
          query: {status: "triggered,acknowledged", assigned_to_user: userId},
          parameters: {status: "resolved"},
          requesterId: userId,
        }, (err, incidents) ->
          if err?
            msg.reply "Something went wrong: #{err}"
          else
            msg.reply "Incidents #{_.map(incidents, "incident_number").join(", ")} resolved"

  robot.respond /pager\s+(?:res(?:olve)?)\s+((?:\d+\s*)+)$/i, (msg) ->
    ids = msg.match[1].split(/\s+/)
    withPagerDutyUserIdOrDefault msg.message.user.email_address, (err, userId) ->
      if err?
        msg.reply "Something went wrong: #{err}"
      else
        filterFn = (incident) -> _.contains(ids, incident.incident_number.toString())
        updateIncidents {
          query: {status: "triggered,acknowledged"},
          filter: filterFn,
          parameters: {status: "resolved"},
          requesterId: userId,
        } , (err) ->
          if err?
            msg.reply "Something went wrong: #{err}"
          else
            msg.reply "Incidents #{ids.join(", ")} resolved"

  robot.respond /pager\s+(?:escalations|policies)/i, (msg) ->
    pagerduty.escalationPolicies {}, (err, policies) ->
      if err?
        msg.reply "Something went wrong: #{err}"
      else
        policies = policies.sort((a, b) -> a.name.localeCompare(b.name))

        response = "<table><tr><th>Policy</th></tr>"
        for policy in policies
          response += "<tr>"
          response += "<td>#{policy.name}</td>"
          response += "</tr>"
        response += "</table>"
        msg.hipchatNotify(response)

  robot.respond /pager\s+(?:override)\s+(\S+)\s+(\S+)$/i, (msg) ->
    scheduleName = msg.match[1]
    durationStr = msg.match[2]

    durationMs = HumanDuration.parseToMilliseconds(durationStr)
    unless durationMs
      msg.reply "Couldn't parse #{durationStr} as a duration. Try, e.g.: 10min, 2hr, 1d"
      return

    withPagerDutyUserId msg.message.user.email_address, (err, userId) ->
      if err?
        msg.reply "Something went wrong: #{err}"
      else
        withBestGuessForSchedule scheduleName, (err, schedule) ->
          if err?
            msg.reply "Something went wrong: #{err}"
          else if schedule
            scheduleOverride schedule.id, userId, durationMs, (err, override) ->
              if err?
                msg.reply "Something went wrong: #{err}"
              else
                msg.reply "Override scheduled for '#{schedule.name}' until #{override.end}"
          else
              msg.reply "😬 I couldn't find any schedule that matched '#{scheduleName}'. Try running !oncall to see a list of schedules."

  if serviceApiKey = process.env.HUBOT_PAGERDUTY_SERVICE_API_KEY
    robot.respond /pager\s+(?:trigger|send|alert)\s+(.+)$/i, (msg) ->
      args = shellquote.parse(msg.match[1])
      return if args.length < 2

      policyOrUser = args.shift()
      alertMessage = args.join(" ")
      withPagerDutyUserIdOrDefault msg.message.user.email_address, (err, userId) ->
        if err?
          msg.reply "Something went wrong: #{err}"
        else
          withBestGuessForEscalationPolicyOrUser policyOrUser, (err, result) ->
            if err?
              msg.reply "Something else wrong: #{err}"
            else if result?.policy or result?.user
              pagerduty.trigger process.env.HUBOT_PAGERDUTY_SERVICE_API_KEY, alertMessage, (err, event) ->
                if err?
                  msg.reply "Something else wrong: #{err}"
                else
                  msg.reply "I triggered your alert. Give me a few seconds to assign it to the correct place."

                  retries = 10
                  assignIncident = ->
                    updateIncidents {
                      query: {incident_key: event.incident_key},
                      parameters: {escalation_policy: result.policy?.id, assigned_to_user: result.user?.id},
                      requesterId: userId,
                    }, (err) ->
                      if err?
                        retries = retries - 1
                        if retries >= 0
                          setTimeout(assignIncident, 1000)
                        else
                          msg.reply "Something went wrong: #{err}"
                      else
                        msg.reply "I assigned your alert to #{(result.policy || result.user)?.name}."

                  setTimeout(assignIncident, 5000)
            else
              msg.reply "😬 I couldn't find any escalation policy or user that matched '#{policyOrUser}'. Try running !pager escalations to see a list of escalation policies."
