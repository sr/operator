# Description:
#   Interacts with Canoe and Artifactory to give information about our deployments.
#
# Configuration:
#   HUBOT_CANOE_HOST
#   HUBOT_CANOE_API_TOKEN
#   HUBOT_CANOE_TARGET_NAME
#   HUBOT_BAMBOO_HOST
#   HUBOT_BAMBOO_USERNAME
#   HUBOT_BAMBOO_PASSWORD
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
Bamboo = require "../lib/bamboo"
date = require "../lib/date"

module.exports = (robot) ->
  canoe = new Canoe(
    process.env.HUBOT_CANOE_HOST || 'https://canoe.dev.pardot.com',
    process.env.HUBOT_CANOE_API_TOKEN
  )
  bamboo = new Bamboo(
    process.env.HUBOT_BAMBOO_HOST || 'https://bamboo.dev.pardot.com',
    process.env.HUBOT_BAMBOO_USERNAME,
    process.env.HUBOT_BAMBOO_PASSWORD
  )

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

    canoe.deploys process.env.HUBOT_CANOE_TARGET_NAME || "production", "pardot", (err, deploys) ->
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
            deployMsg += "#{previousDeploy.branch}/build#{previousDeploy.build_number}...#{deploy.branch}/build#{deploy.build_number}"
            deployMsg += "</a>"
          else
            deployMsg += "<a href=\"https://git.dev.pardot.com/pardot/pardot/tree/#{deploy.sha}\">"
            deployMsg += "#{deploy.branch}/build#{deploy.build_number}"
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
    async.parallel
      latestDeploy: (cb) ->
        canoe.deploys process.env.HUBOT_CANOE_TARGET_NAME || "production", "pardot", (err, deploys) ->
          if err?
            cb(err, null)
          else
            cb(null, deploys[0])
      latestBuild: (cb) ->
        canoe.builds "pardot", "master", 10, (err, builds) ->
          if err?
            cb(err, null)
          else
            cb(null, builds[0])
      inProgressBuilds: (cb) ->
        bamboo.inProgressBuilds 'PDT-PPANT', (err, builds) ->
          if err?
            console.log "bamboo err: #{err}"
            cb(err, null)
          else
            console.log builds
            async.map builds,
              (b, cb) -> console.log(b); bamboo.buildStatus(b.key, cb),
              cb
    , (err, result) ->
      prettifiedInProgressBuilds = _.chain(result.inProgressBuilds)
        .select((r) -> r.progress)
        .map((r) -> "<a href=\"#{bamboo.host}/browse/#{r.key}\">master/build#{_.last(r.key.split('-'))}</a>: #{r.progress.prettyTimeRemainingLong}")
        .join("<br>")
        .value()

      if err?
        msg.send "Something went wrong: #{err}"
      else
        if result.latestDeploy.branch == "master" and result.latestDeploy.build_number == result.latestBuild.build_number
          msg.hipchatNotify "Looks like we are up to date. <img src=\"https://hipchat.dev.pardot.com/files/img/emoticons/1/buttrock-1423164525.gif\"><br><br>#{prettifiedInProgressBuilds}"
        else
          githubLink = "https://git.dev.pardot.com/pardot/pardot/compare/#{result.latestDeploy.sha}...#{result.latestBuild.sha}"
          msg.hipchatNotify "Changes on deck: <b><a href=\"#{githubLink}\">#{result.latestDeploy.branch}/build#{result.latestDeploy.build_number}...master/build#{result.latestBuild.build_number}</a></b><br><br>#{prettifiedInProgressBuilds}"
