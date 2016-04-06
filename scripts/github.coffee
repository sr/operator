# Description:
#  gets pull requests and things
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot pr - does nothing yet
# Author:
#   JERN UHRMERN

GithubApiWrapper = require "../lib/github/github_api_wrapper"

module.exports = (robot) ->
  robot.respond /pr/i, (msg) ->
    github = new GithubApiWrapper()
    github.pulls (pr) ->
        console.log pr
        msg.send pr
