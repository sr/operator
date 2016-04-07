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
#   hubot pr for user - does nothing yet
#   hubot pr for repo - does nothing yet
#   hubot pr for user - does nothing yet
#   hubot pr add repo - does nothing yet
#   hubot pr add user - does nothing yet
#   hubot pr list user - does nothing yet
#   hubot pr list repo - does nothing yet
#   hubot pr reset user - does nothing yet
#   hubot pr reset repo - does nothing yet
# Author:
#   JERN UHRMERN and GERGE GERSSERN

GithubApiWrapper = require "../lib/github/github_api_wrapper"
GithubRobotBrain = require "../lib/github/github_robot_brain"
PullRequestUtils = require "../lib/github/pull_request_utils"

module.exports = (robot) ->

  robot.respond /pr$/i, (msg) ->
    robotBrain = new GithubRobotBrain
    github = new GithubApiWrapper()
    github.repos = robotBrain.getRepoListForRoom(robot, msg.message.user.room)
    github.users = robotBrain.getUserListForRoom(robot, msg.message.user.room)
    github.pulls prCallback, msg

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

  robot.respond /pr add repo\s+(.*)$/i, (msg) ->
    repo = msg.match[1]
    robotBrain = new GithubRobotBrain
    robotBrain.addRepoToRoomList(robot, msg.message.user.room, repo)

  robot.respond /pr add user\s+(.*)$/i, (msg) ->
    username = msg.match[1]
    robotBrain = new GithubRobotBrain
    robotBrain.addUserToRoomList(robot, msg.message.user.room, username)

  robot.respond /pr remove repo\s+(.*)$/i, (msg) ->
    repo = msg.match[1]
    robotBrain = new GithubRobotBrain
    robotBrain.removeRepoFromRoomList(robot, msg.message.user.room, repo)

  robot.respond /pr remove user\s+(.*)$/i, (msg) ->
    username = msg.match[1]
    robotBrain = new GithubRobotBrain
    robotBrain.removeUserFromRoomList(robot, msg.message.user.room, username)

  robot.respond /pr list user/i, (msg) ->
    robotBrain = new GithubRobotBrain
    users = robotBrain.getUserListForRoom(robot, msg.message.user.room)
    if !users || users.length < 1
      msg.send("There are no saved users for this room")
    else
      msg.send("These are the users for this room: " + users.toString())

  robot.respond /pr list repo/i, (msg) ->
    robotBrain = new GithubRobotBrain
    repos = robotBrain.getRepoListForRoom(robot, msg.message.user.room)
    if !repos || repos.length < 1
      msg.send("There are no saved repos for this room")
    else
      msg.send("These are the repos for this room: " + repos.toString())

  robot.respond /pr reset user list$/i, (msg) ->
    robotBrain = new GithubRobotBrain
    robotBrain.resetRoomUserList(robot, msg.message.user.room)

  robot.respond /pr reset repo list$/i, (msg) ->
    robotBrain = new GithubRobotBrain
    robotBrain.resetRoomRepoList(robot, msg.message.user.room)

prCallback = (prTable, msg) ->
    msg.hipchatNotify "<strong>Pull Requests: </strong>#{prTable}", {color: "green"}
