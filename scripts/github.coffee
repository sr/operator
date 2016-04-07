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
#   hubot pr - does nothing yet
#   hubot pr - does nothing yet
#   hubot pr - does nothing yet
#   hubot pr - does nothing yet
#   hubot pr - does nothing yet
#   hubot pr - does nothing yet
# Author:
#   JERN UHRMERN and GERGE GERSSERN

GithubApiWrapper = require "../lib/github/github_api_wrapper"
GithubRobotBrain = require "../lib/github/github_robot_brain"
PullRequestUtils = require "../lib/github/pull_request_utils"

module.exports = (robot) ->
  robot.respond /pr for user (.*)$/i, (msg) ->
    github = new GithubApiWrapper()
    github.pulls prCallback, msg, ['pardot'], [msg.match[1]]

  robot.respond /pr for repo (.*)$/i, (msg) ->
    github = new GithubApiWrapper()
    github.pulls prCallback, msg, [msg.match[1]]

  robot.respond /pr for user (.*) in repo (.*)$/i, (msg) ->
    github = new GithubApiWrapper()
    github.pulls prCallback, msg, [msg.match[2]], [msg.match[1]]

  robot.respond /pr$/i, (msg) ->
    rooms = robot.brain.get(USER_KEY)
    if !rooms[msg.message.user.room]
      msg.send("We ain\'t found no pull requests")
    else
      github = new GithubApiWrapper()
      github.pulls prCallback, msg, ['pardot'], rooms[msg.message.user.room]

  robot.respond /prAddRepo\s+(.*)$/i, (msg) ->
    repo = msg.match[1]
    robotBrain = new GithubRobotBrain
    robotBrain.addRepoToRoomList(robot, msg.message.user.room, repo)

  robot.respond /prAddUser\s+(.*)$/i, (msg) ->
    username = msg.match[1]
    robotBrain = new GithubRobotBrain
    robotBrain.addUserToRoomList(robot, msg.message.user.room, username)

  robot.respond /prListUsers/i, (msg) ->
    robotBrain = new GithubRobotBrain
    users = robotBrain.getUserListForRoom(robot, msg.message.user.room)
    if !users || users.length < 1
      msg.send("There are no saved users for this room")
    else
      msg.send("These are the users for this room: " + users.toString())

  robot.respond /prListRepos/i, (msg) ->
    robotBrain = new GithubRobotBrain
    repos = robotBrain.getRepoListForRoom(robot, msg.message.user.room)
    if !repos || repos.length < 1
      msg.send("There are no saved repos for this room")
    else
      msg.send("These are the repos for this room: " + repos.toString())

  robot.respond /prResetUserList$/i, (msg) ->
    robotBrain = new GithubRobotBrain
    robotBrain.resetRoomUserList(robot, msg.message.user.room)

  robot.respond /prResetRepoList$/i, (msg) ->
    robotBrain = new GithubRobotBrain
    robotBrain.resetRoomRepoList(robot, msg.message.user.room)

prCallback = (prTable, msg) ->
    msg.hipchatNotify "<strong>Pull Requests: </strong>#{prTable}", {color: "green"}
