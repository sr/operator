
REPO_KEY = 'prRepoList'
USER_KEY = 'prUsersList'

class GithubRobotBrain

  getUserListForRoom: (robot, roomId) ->
    @getRoomListGeneric(robot, roomId, USER_KEY)

  addUserToRoomList: (robot, roomId, user) ->
    @addToRoomListGeneric(robot, roomId, USER_KEY, user)

  removeUserFromRoomList: (robot, roomId, user) ->
    console.log("removing" + user)
    @removeFromRoomListGeneric(robot, roomId, USER_KEY, user)

  getRepoListForRoom: (robot, roomId) ->
    @getRoomListGeneric(robot, roomId, REPO_KEY)

  addRepoToRoomList: (robot, roomId, repo) ->
    @addToRoomListGeneric(robot, roomId, REPO_KEY, repo)

  removeRepoFromRoomList: (robot, roomId, repo) ->
    console.log("removing" + repo)
    @removeFromRoomListGeneric(robot, roomId, REPO_KEY, repo)

  resetRoomUserList: (robot, roomId) ->
    @resetGenericRoomList(robot, roomId, USER_KEY)

  resetRoomRepoList: (robot, roomId) ->
    @resetGenericRoomList(robot, roomId, REPO_KEY)

  resetGenericRoomList: (robot, roomId, key) ->
    if !robot.brain.get(key)
      robot.brain.set(key, {})
    rooms = robot.brain.get(key)
    rooms[roomId] = []
    robot.brain.set(key, rooms)

  getRoomListGeneric: (robot, roomId, key) ->
    if !robot.brain.get(key)
      robot.brain.set(key, {})

    rooms = robot.brain.get(key)
    if !rooms[roomId]
      []
    else
      rooms[roomId]

  addToRoomListGeneric: (robot, roomId, key, value) ->
    if !robot.brain.get(key)
      robot.brain.set(key, {})
    rooms = robot.brain.get(key)
    if !rooms[roomId]
      rooms[roomId] = []
    rooms[roomId].push value
    robot.brain.set(key, rooms)

  removeFromRoomListGeneric: (robot, roomId, key, value) ->
    if !robot.brain.get(key)
      robot.brain.set(key, {})
    rooms = robot.brain.get(key)
    if !rooms[roomId]
      rooms[roomId] = []
    else
      index = rooms[roomId].indexOf(value);
      if index != -1
        rooms[roomId].splice(index, 1);
    robot.brain.set(key, rooms)

module.exports = GithubRobotBrain
