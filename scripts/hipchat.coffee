# Description:
#   Adds Hipchat-specific functionality to Hubot.
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_HIPCHAT_HOST
#   HUBOT_HIPCHAT_TOKEN
#
# Commands:
#   None
#
# Author:
#   alindeman

require("dotenv").load(silent: true)

_ = require "underscore"
scopedHttpClient = require "scoped-http-client"
async = require "async"

class Hipchat
  constructor: (@host, @token) ->
    @client = scopedHttpClient.create("https://#{@host}")
      .query("auth_token", @token)

  rooms: (cb) ->
    @client.query("max-results", "1000")
      .path("/v2/room")
      .get() (err, resp, body) ->
        if err?
          cb(err, null) if cb
        else
          try
            cb(null, JSON.parse(body)) if cb
          catch err
            cb(err, null) if cb

  room: (id, cb) ->
    @client.path("/v2/room/#{id}")
      .get() (err, resp, body) ->
        if err?
          cb(err, null) if cb
        else
          try
            cb(null, JSON.parse(body)) if cb
          catch err
            cb(err, null) if cb

  messageRoom: (id, text, cb) ->
    @client.path("/v2/room/#{id}/message")
      .header("content-type", "application/json")
      .post(JSON.stringify(message: text)) (err, resp, body) ->
        if err?
          cb(err, null) if cb
        else
          try
            cb(null, JSON.parse(body)) if cb
          catch err
            cb(err, null) if cb

  # For valid params, see: <https://www.hipchat.com/docs/apiv2/method/send_room_notification>
  notifyRoom: (id, params, cb) ->
    @client.path("/v2/room/#{id}/notification")
      .header("content-type", "application/json")
      .post(JSON.stringify(params)) (err, resp, body) ->
        if err?
          cb(err, null) if cb
        else
          try
            cb(null, JSON.parse(body)) if cb
          catch err
            cb(err, null) if cb

class JidMapping
  BRAIN_KEY = "hipchat-jid-mapping"

  constructor: (@hipchat, @brain) ->

  get: (jid) ->
    @_ensureBrainInitialized()
    @brain.get(BRAIN_KEY)[jid]

  set: (jid, id) ->
    @_ensureBrainInitialized()
    @brain.get(BRAIN_KEY)[jid] = id

  all: ->
    @_ensureBrainInitialized()
    @brain.get(BRAIN_KEY)

  _ensureBrainInitialized: ->
    @brain.set(BRAIN_KEY, {}) unless @brain.get(BRAIN_KEY)?

  updateMappings: (cb) ->
    @hipchat.rooms (err, resp) =>
      if err?
        console.log err
        cb(err) if cb
      else
        queue = async.queue (room, qcb) =>
          # Since API calls are expensive, avoid refetching if the mapping
          # already exists.
          if _.has(_.invert(@all()), room.id)
            qcb()
          else
            @hipchat.room room.id, (err, resp) =>
              if err?
                console.log err
              else if resp.xmpp_jid?
                @set(resp.xmpp_jid, resp.id)

            # Hipchat API limits are 100 requests per 5 minutes.
            # Or one request every 3 seconds, on average.
            setTimeout qcb, 4 * 1000

        resp.items.forEach (room) -> queue.push(room)
        queue.drain = -> cb(null) if cb

module.exports = (robot) ->
  hipchat = new Hipchat(process.env.HUBOT_HIPCHAT_HOST, process.env.HUBOT_HIPCHAT_TOKEN)
  mapping = new JidMapping(hipchat, robot.brain)

  # Periodically refresh the mappings in case new rooms were created.
  updating = false
  updateMappings = ->
    console.log "Updating mappings, maybe"
    return if updating

    updating = true
    mapping.updateMappings()
    updating = false

  setInterval(updateMappings, 1000 * 60 * 10)
  setTimeout(updateMappings, 0)

  hipchatRoomNotify = (robot, roomJid, text, options) ->
    if roomId = mapping.get(roomJid)
      hipchat.notifyRoom roomId, _.extend({}, options || {}, message: text)
    else
      robot.send roomJid, text

  robot.listenerMiddleware (context, next, done) ->
    # Adds the hipchatNotify function to the msg object in listeners
    context.response.hipchatNotify = (text, options) ->
      hipchatRoomNotify(robot, context.response.envelope?.user?.reply_to, text, options)

    # Adds the hipchatNotifyRoom function to the msg object in listeners
    context.response.hipchatNotifyRoom = (roomJid, text, options) ->
      hipchatRoomNotify(robot, roomJid, text, options)

    next(done)
