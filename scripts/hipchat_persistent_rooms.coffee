# Description:
#   Keeps a list of rooms the bot has been invited to in the brain so it can
#   rejoin them after restarts.
#
# Dependencies:
#   None
#
# Commands:
#
# Author:
#   alindeman

_ = require "underscore"

class HipchatPersistentRoomList
  BRAIN_KEY = "hipchat-persistent-room-list"

  constructor: (@adapter, @brain) ->

  all: ->
    @_ensureBrainInitialized()
    @brain.get(BRAIN_KEY)

  add: (jid) ->
    @_ensureBrainInitialized()
    @all().push(jid) unless _.contains(@all(), jid)

  joinAll: ->
    for jid in @all()
      @adapter.connector.join(jid)

  _ensureBrainInitialized: ->
    @brain.set(BRAIN_KEY, []) unless @brain.get(BRAIN_KEY)?

module.exports = (robot) ->
  # only relevant when the hipchat adapter is being used
  if robot?.adapter?.connector?.join
    persistentRoomList = new HipchatPersistentRoomList(robot.adapter, robot.brain)
    robot.brain.on "loaded", -> persistentRoomList.joinAll()

    robot.enter (res) ->
      myJid = robot.adapter?.options?.jid
      if myJid? and myJid == res.message.user.jid
        persistentRoomList.add(res.message.user.room)
