# Description
#   Warns folks that @here and @all are really distracting in large channels
#
# Configuration:
#   HUBOT_HERE_WARNING_MINIMUM
#

_ = require "underscore"

warningMinimum = parseInt(process.env.HUBOT_HERE_WARNING_MINIMUM || "25")

roomIsOkToUseHere = (roomJid, roomName) ->
  # support folks use @here while on calls or chats
  # salesforce managed package room has requested it be disabled
  roomName.match(/(support|solutions)/i) || \
    roomName.match(/salesedge/i)

module.exports = (robot) ->
  robot.hear /@(here|all)/, (msg) ->
    return unless msg.hipchatRoomParticipants

    roomJid = msg.envelope?.user?.reply_to
    roomName = msg.envelope?.room
    if roomJid && roomName && !roomIsOkToUseHere(roomJid, roomName)
      msg.hipchatRoomParticipants roomJid, (err, participants) ->
        if err?
          console.log "Error getting room participants: #{err}"
        else if participants?.items?.length >= warningMinimum
          console.log "Warned #{msg.envelope.user.jid} of @#{msg.match[1]} in #{roomName}/#{roomJid}"
          robot.send user: msg.envelope.user.jid, "Hey, please take care using [@]#{msg.match[1]} in large channels. Instead, consider using an asynchronous form of communication if appropriate. Some suggestions: Chatter for discussion or announcements, JIRA or GUS for work items, Quip for collaborating on documents."
