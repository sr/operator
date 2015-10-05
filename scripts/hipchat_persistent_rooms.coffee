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
  BRAIN_KEY = "hipchat-persistent-room-list2"

  constructor: (@adapter, @brain) ->

  all: ->
    @_ensureBrainInitialized()
    _.keys(@brain.get(BRAIN_KEY))

  add: (jid) ->
    return unless jid? && jid.match(/@/)

    @_ensureBrainInitialized()
    @brain.get(BRAIN_KEY)[jid] = 1

  joinAll: ->
    for jid in @all()
      @adapter.connector.join(jid)

  _ensureBrainInitialized: ->
    @brain.set(BRAIN_KEY, {}) unless @brain.get(BRAIN_KEY)?

module.exports = (robot) ->
  # only relevant when the hipchat adapter is being used
  if robot?.adapter?.connector?.join
    persistentRoomList = new HipchatPersistentRoomList(robot.adapter, robot.brain)
    robot.brain.on "loaded", -> persistentRoomList.joinAll()

    robot.receiveMiddleware (context, next, done) ->
      persistentRoomList.add(context.response?.envelope?.room)
      next(done)

    robot.enter (res) ->
      persistentRoomList.add(res.message.user.room)
