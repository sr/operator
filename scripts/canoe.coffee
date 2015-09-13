# Description:
#   Tracks deploy messages from Canoe
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot lastrelease - Returns the last deploy
#   hubot lastrelease <num> - Returns the <num> last deploys
#   hubot ondeck - Returns the difference between the last production deploy and the latest build

builds = require "../lib/builds"
deploys = require "../lib/deploys"
formatDateString = require("../lib/date").formatDateString

module.exports = (robot) ->
  buildClient = builds.createClient()
  deployClient = deploys.createClient()

  robot.hear /^PROD\: (\S+) just began syncing Pardot to .*?build(\d+).*? on ([\w\.\-]*)/, (msg) ->
    syncMaster = msg.match[1]
    buildNumber = msg.match[2]

    deployClient.add(syncMaster, buildNumber)

  robot.respond /lastrelease\s*(\d*)$/i, (msg) ->
    numDeploys = parseInt(msg.match[1] || "1")
    numDeploys = 10 if numDeploys > 10

    deployClient.latest numDeploys, (err, r) ->
      if err
        msg.reply "Something went wrong: #{err}"
      else
        return unless r and r[0]

        msgs = []
        for deploy in r
          githubLink = "https://git.dev.pardot.com/pardot/pardot/tree/build#{deploy.build_number}"
          msgs.push "#{deploy.sync_master} synced build#{deploy.build_number} synced on #{formatDateString(deploy.started_at)}: #{githubLink}"

        msg.send msgs.join("\n")

  robot.respond /ondeck/i, (msg) ->
    buildClient.latest 1, (err, r) ->
      return unless r and r[0]
      latestBuiltBuildNumber = r[0].build_number
      deployClient.latest 1, (err, r) ->
        return unless r and r[0]
        latestDeployedBuildNumber = r[0].build_number

        if latestBuiltBuildNumber == latestDeployedBuildNumber
          msg.reply "Looks like we are up to date. (buttrock)"
        else
          githubLink = "https://git.dev.pardot.com/pardot/pardot/compare/build#{latestDeployedBuildNumber}...build#{latestBuiltBuildNumber}"
          msg.reply "Changes on deck: build#{latestDeployedBuildNumber}...build#{latestBuiltBuildNumber}: #{githubLink}"
