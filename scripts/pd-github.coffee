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
#   hubot pr - lists all of the prs for all of the repos and users associated with the current room (defaults to all repos and all users)
#   hubot pr for user <github username> - gets all prs for this user in any repos you have associated with this room. All repos if you have not defined any repos
#   hubot pr for repo <repo name> - gets all prs for the specified repo for any users you have associated with this room. Defaults to all repos
#   hubot pr for user <github username> in repo <repo name>  - gets all prs for the specified user in the specified repo
#   hubot pr add repo <repo name> - adds a repo to the current room, for use with the !pr and !pr for user commands
#   hubot pr add user <github username> - adds a user to the current room, for use with the !pr and !pr for repo commands
#   hubot pr remove repo <repo name> - removes a repo from the current rooms repo list, for use with the !pr and !pr for repo commands
#   hubot pr remove user <github username> - removes a user from the current rooms user list, for use with the !pr and !pr for repo commands
#   hubot pr list user - lists all of the github users associated with the current room
#   hubot pr list repo - lists all of the repos associated with the current room
#   hubot pr reset user - removes all of the github users associated with the current room
#   hubot pr reset repo - removes all of the repos associated with this room
# Author:
#   JERN UHRMERN and GERGE GERSSERN

GithubApiWrapper = require "../lib/github/github_api_wrapper"
GithubRobotBrain = require "../lib/github/github_robot_brain"

module.exports = (robot) ->

  robot.respond /pr$/i, (msg) ->
    robotBrain = new GithubRobotBrain
    github = new GithubApiWrapper()
    github.repos = robotBrain.getRepoListForRoom(robot, msg.message.user.room)
    github.users = robotBrain.getUserListForRoom(robot, msg.message.user.room)
    github.pulls prCallback, msg

  robot.respond /pr (repo|user)/i, (msg) ->
    msg.send("Invalid Syntax. Valid Syntax Examples: '! pr add user' or '! pr remove repo'")

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
    msg.send(repo + " has been added to this room's repo list")

  robot.respond /pr add user\s+(.*)$/i, (msg) ->
    username = msg.match[1]
    robotBrain = new GithubRobotBrain
    robotBrain.addUserToRoomList(robot, msg.message.user.room, username)
    msg.send(username + " has been added to this room's user list")

  robot.respond /pr remove repo\s+(.*)$/i, (msg) ->
    repo = msg.match[1]
    robotBrain = new GithubRobotBrain
    robotBrain.removeRepoFromRoomList(robot, msg.message.user.room, repo)
    msg.send(repo + " has been removed from this room's repo list")

  robot.respond /pr remove user\s+(.*)$/i, (msg) ->
    username = msg.match[1]
    robotBrain = new GithubRobotBrain
    robotBrain.removeUserFromRoomList(robot, msg.message.user.room, username)
    msg.send(username + " has been removed from this room's user list")

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
    msg.send("All users for this room's pr list have been removed")

  robot.respond /pr reset repo list$/i, (msg) ->
    robotBrain = new GithubRobotBrain
    robotBrain.resetRoomRepoList(robot, msg.message.user.room)
    msg.send("All repos for this room's pr list have been removed")

prCallback = (prTable, msg) ->
    msg.hipchatNotify "<strong>Pull Requests: </strong>#{prTable}", {color: "green"}
