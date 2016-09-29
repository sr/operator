# Description
#   Warns folks that @here and @all are really distracting in large channels
#
# Configuration:
#   HUBOT_HERE_WARNING_MINIMUM
#

_ = require "underscore"

warningMinimum = parseInt(process.env.HUBOT_HERE_WARNING_MINIMUM || "25")

roomIsOkToUseHere = (roomJid, roomName) ->
  if roomName.match(/(not_solutions_for_work|support|solutions_team)/i) # support folks use @here while on calls or chats
    true
  else
    false

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
          robot.send user: msg.envelope.user.jid, "(disapproval) Please take care using [@]#{msg.match[1]} in large channels. Up to #{participants.items.length} people received a ping just now. Instead, consider using an asynchronous form of communication if appropriate. Some suggestions: Chatter for discussion or announcements, JIRA or GUS for work items, Quip for collaborating on documents"
