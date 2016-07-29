# Description:
#   Interacts with Canoe and Artifactory to give information about our deployments.
#
# Configuration:
#   HUBOT_CANOE_HOST
#   HUBOT_CANOE_API_TOKEN
#   HUBOT_CANOE_TARGET_NAME
#
# Commands:
#   hubot lastrelease - Returns information about the last Pardot sync
#   hubot lastrelease <number> - Returns information aboout the last <number> Pardot syncs
#   hubot lastbuild - Returns the last successful builds of the Pardot repo
#   hubot lastbuild <number> - Returns the last <number> successful builds of the Pardot repo
#   hubot ondeck - Returns the difference between the last Pardot sync and the last Pardot build
#
# Author:
#   alindeman

require("dotenv").load(silent: true)

_ = require "underscore"
async = require "async"
eachCons = require "each-cons"

Canoe = require "../lib/canoe"
date = require "../lib/date"

module.exports = (robot) ->
  canoe = new Canoe(process.env.HUBOT_CANOE_HOST, process.env.HUBOT_CANOE_API_TOKEN)

  robot.respond /doc(?:s)?\s*(.*)?/i, (msg) ->
    conf = "https://confluence.dev.pardot.com/"
    resp = "Confluence"
    if msg.match[1]
      conf += "dosearchsite.action?queryString=#{msg.match[1]}"
      resp += " Search Results"
    html = "<a href=\"#{conf}\">#{resp}</a>"
    msg.hipchatNotify(html, {color: "gray"})

  robot.respond /last(?:releases?|syncs?)(?:\s+(\d+))?$/i, (msg) ->
    number = _.min([10, parseInt(msg.match[1] || "1")])

    canoe.deploys process.env.HUBOT_CANOE_TARGET_NAME, "pardot", (err, deploys) ->
      if err?
        msg.send "Something went wrong: #{err}"
      else
        msgs = []

        deploys.push(null)
        deploys = deploys[0..number]

        for [deploy, previousDeploy] in eachCons(deploys[0..number], 2)
          deployMsg = "<a href=\"mailto:#{deploy.user}\">#{deploy.user}</a> synced "
          if previousDeploy
            deployMsg += "<a href=\"https://git.dev.pardot.com/pardot/pardot/compare/#{previousDeploy.sha}...#{deploy.sha}\">"
            deployMsg += "#{previousDeploy.what_details}/build#{previousDeploy.build_number}...#{deploy.what_details}/build#{deploy.build_number}"
            deployMsg += "</a>"
          else
            deployMsg += "<a href=\"https://git.dev.pardot.com/pardot/pardot/tree/#{deploy.sha}\">"
            deployMsg += "#{deploy.what_details}/build#{deploy.build_number}"
            deployMsg += "</a>"
          deployMsg += " on #{date.formatDateString(deploy.created_at)}"

          msgs.push(deployMsg)

        msg.hipchatNotify msgs.join("<br>\n")

  robot.respond /last(?:builds?)(?:\s+(\d+))?$/i, (msg) ->
    number = _.min([10, parseInt(msg.match[1] || "1")])

    # The builds are sorted by created at date, so we must request more than we
    # expected to need. It's not possible with Artifactory to sort builds by
    # build number.
    canoe.builds "pardot", "master", number * 3, (err, builds) ->
      if err?
        msg.send "Something went wrong: #{err}"
      else
        msgs = []

        for build in builds[0...number]
          buildMsg  = "<a href=\"https://git.dev.pardot.com/pardot/pardot/tree/#{build.sha}\">master/build#{build.build_number}</a> "
          buildMsg += "passed on #{date.formatDateString(build.created_at)}"
          msgs.push(buildMsg)

        msg.hipchatNotify msgs.join("<br>\n")

  robot.respond /ondeck$/i, (msg) ->
    async.parallel [
      (cb) ->
        canoe.deploys process.env.HUBOT_CANOE_TARGET_NAME, "pardot", (err, deploys) ->
          if err?
            cb(err, null)
          else
            cb(null, deploys[0])
      , (cb) ->
        canoe.builds "pardot", "master", 10, (err, builds) ->
          if err?
            cb(err, null)
          else
            cb(null, builds[0])
    ], (err, results) ->
      if err?
        msg.send "Something went wrong: #{err}"
      else
        deploy = results[0]
        build = results[1]

        if deploy.what_details == "master" and deploy.build_number == build.build_number
          msg.send "Looks like we are up to date. (buttrock)"
        else
          githubLink = "https://git.dev.pardot.com/pardot/pardot/compare/#{deploy.sha}...#{build.sha}"
          msg.hipchatNotify "Changes on deck: <a href=\"#{githubLink}\">#{deploy.what_details}/build#{deploy.build_number}...master/build#{build.build_number}</a>"
