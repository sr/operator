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
PullRequestUtils = require "../lib/github/pull_request_utils"

module.exports = (robot) ->
  robot.respond /pr for user (.*)$/i, (msg) ->
    github = new GithubApiWrapper()
    github.pulls prCallback, msg, [msg.match[1]]

  robot.respond /pr$/i, (msg) ->
    github = new GithubApiWrapper()
    pullRequestUtils = new PullRequestUtils()
    github.pulls prCallback, msg

prCallback = (prTable, msg) ->
    msg.hipchatNotify "<strong>Pull Requests: </strong>#{prTable}", {color: "green"}
