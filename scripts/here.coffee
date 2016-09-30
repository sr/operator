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
    roomName.match(/salesedge/i) || \
    roomName.match(/missile_command/i)

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
          robot.send user: msg.envelope.user.jid, "Hey, please take care using [@]#{msg.match[1]} in large channels. It can be pretty distracting. Also consider that chat is an ephemeral and lossy form of communication. It's the online equivalent of standing up and yelling in at everyone in an office. If possible, consider using an asynchronous form of communication. Some suggestions: Chatter for discussion or announcements, JIRA or GUS for work items, Quip for collaborating on documents. If you feel that [@]#{msg.match[1]} is a necessary part of this channel's workflow though, you can file a JIRA ticket in the BREAD project to have it added to the whitelist."
