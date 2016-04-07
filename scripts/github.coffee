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
#   JERN UHRMERN and GERGE GERSSERN

GithubApiWrapper = require "../lib/github/github_api_wrapper"
PullRequestUtils = require "../lib/github/pull_request_utils"

STORE_KEY = 'prUsersList'

module.exports = (robot) ->
  robot.respond /pr for user (.*)$/i, (msg) ->
    github = new GithubApiWrapper()
    github.repos = ['pardot']
    github.users = [msg.match[1]]
    github.pulls prCallback, msg

  robot.respond /pr for repo (.*)$/i, (msg) ->
    github = new GithubApiWrapper()
    github.repos = [msg.match[1]]
    github.pulls prCallback, msg

  robot.respond /pr for user (.*) in repo (.*)$/i, (msg) ->
    github = new GithubApiWrapper()
    github.repos = [msg.match[2]]
    github.users = [msg.match[1]]
    github.pulls prCallback, msg

  robot.respond /pr$/i, (msg) ->
    rooms = robot.brain.get(STORE_KEY)
    if !rooms[msg.message.user.room]
      msg.send("We ain\'t found no pull requests")
    else
      github = new GithubApiWrapper()
      github.pulls prCallback, msg, ['pardot'], rooms[msg.message.user.room]


  robot.respond /prAddUser\s+(.*)$/i, (msg) ->
    username = msg.match[1]
    if !robot.brain.get(STORE_KEY)
      robot.brain.set(STORE_KEY, {})

    rooms = robot.brain.get(STORE_KEY)
    if !rooms[msg.message.user.room]
      users = []
    else
      users = rooms[msg.message.user.room]
    users.push username
    rooms[msg.message.user.room] = users
    robot.brain.set(STORE_KEY, rooms)

  robot.respond /prListUsers/i, (msg) ->
    rooms = robot.brain.get(STORE_KEY)
    if !rooms[msg.message.user.room]
      msg.send("There are no saved users for this room")
    else
      msg.send(rooms[msg.message.user.room].toString())

  robot.respond /prResetUserList$/i, (msg) ->
    robot.brain.set(STORE_KEY, {})

prCallback = (prTable, msg) ->
    msg.hipchatNotify "<strong>Pull Requests: </strong>#{prTable}", {color: "green"}
