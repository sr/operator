# Description:
#   Tracks build status messages from Bamboo
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot lastbuild - Returns the last successful build
#   hubot lastbuild <num> - Returns the <num> last successful builds

builds = require "../lib/builds"
formatDateString = require("../lib/date").formatDateString

module.exports = (robot) ->
  client = builds.createClient()

  robot.hear /Pardot . Pardot PHP [^#]+ \#(\d*)[^\d]*? passed/, (msg) ->
    return if msg.message.text.match(/›/g).length isnt 2

    buildNumber = msg.match[1]
    client.add(buildNumber)

  robot.respond /lastbuild\s*(\d*)$/i, (msg) ->
    numBuilds = parseInt(msg.match[1] || "1")
    numBuilds = 10 if numBuilds > 10

    client.latest numBuilds, (err, r) ->
      if err
        msg.reply "Something went wrong: #{err}"
      else
        return unless r and r[0]
        for build in r
          githubLink = "https://git.dev.pardot.com/pardot/pardot/tree/build#{build.build_number}"
          msg.send "build#{build.build_number} passed on #{formatDateString(build.completed_at)}: #{githubLink}"
