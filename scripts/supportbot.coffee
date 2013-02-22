# Description:
#   SupportBot commands
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   None
#

sys  = require "sys"
exec = require "child_process"
exec = exec.exec

util = require "../lib/util"

module.exports = (robot) ->
    # Add new ticket
    robot.hear /^!add\s+(.*)/i, (msg) ->
        if !supportBotEnabled then return
        info = joinInfo msg.match[1].split " "

        sendSupportCommand "addTicket #{msg.message.user.name}", info, msg

    # Add more to a ticket
    robot.hear /^!(\d+)\s+(.*)$/i, (msg) ->
        if !supportBotEnabled then return
        ticket = msg.match[1]
        info   = joinInfo msg.match[2].split " "

        sendSupportCommand "addMoreToTicket #{ticket}", info + " #{msg.message.user.name}", msg

    # Close a ticket
    robot.hear /^!close\s+(\d+)\s*(.*)$/i, (msg) ->
        if !supportBotEnabled then return
        ticket = msg.match[1]
        info   = joinInfo msg.match[2].split " "

        sendSupportCommand "closeTicket #{ticket}", "#{msg.message.user.name} #{info}", msg

    # Open a ticket
    robot.hear /^!open\s+(\d+)$/i, (msg) ->
        if !supportBotEnabled then return
        ticket = msg.match[1]

        sendSupportCommand "openTicket #{ticket}", "#{msg.message.user.name}", msg

    # WOC a ticket
    robot.hear /^!woc\s+(\d+)$/i, (msg) ->
        if !supportBotEnabled then return
        ticket = msg.match[1]

        sendSupportCommand "wocTicket #{ticket}", "#{msg.message.user.name}", msg

    # Watch a ticket
    robot.hear /^!watch\s+(\d+)$/i, (msg) ->
        if !supportBotEnabled then return
        ticket = msg.match[1]

        sendSupportCommand "ircNotifyTicket", "#{msg.message.user.name} watch #{ticket}", msg

    robot.hear /^!notify\s+(\d+)\s+(.+)$/i, (msg) ->
        if !supportBotEnabled then return
        ticket = msg.match[1]
        notify = msg.match[2]

        sendSupportCommand "ircNotifyTicket", "#{notify} watch #{ticket}", msg

    # Ignore a ticket
    robot.hear /^!ignore\s+(\d+)$/i, (msg) ->
        if !supportBotEnabled then return
        ticket = msg.match[1]

        sendSupportCommand "ircNotifyTicket", "#{msg.message.user.name} ignore #{ticket}", msg

    # What tickets am I watching
    robot.hear /^!watching$/i, (msg) ->
        if !supportBotEnabled then return
        sendSupportCommand "ircNotifyTicket", "#{msg.message.user.name} info", msg

    # Overall ticket status
    robot.hear /^!status$/i, (msg) ->
        if !supportBotEnabled then return
        sendSupportCommand "status", "#{msg.message.user.name}", msg

    # Specific ticket status
    robot.hear /^!status\s+(\d+)$/i, (msg) ->
        if !supportBotEnabled then return
        ticket = msg.match[1]

        sendSupportCommand "status", ticket, msg
        
    # Give a ticket
    robot.hear /^!give\s+(\d+)\s+(.*)$/i, (msg) ->
        if !supportBotEnabled then return
        ticket = msg.match[1]
        user   = msg.match[2]

        users = util.getAllNicks msg
        index = users.indexOf user

        if index is -1
            msg.send "#{user} does not exist!"
        else
            sendSupportCommand "assignTicket", "#{ticket} #{user} #{msg.message.user.name}", msg

    # Take a ticket
    robot.hear /^!take\s+(\d+)$/i, (msg) ->
        if !supportBotEnabled then return
        ticket = msg.match[1]

        sendSupportCommand "assignTicket", "#{ticket} #{msg.message.user.name} #{msg.message.user.name}", msg

        
# Execute a supportbot task on the terminal
sendSupportCommand = (command, arg, msg) ->
    console.log "Running: #{process.env.SUPPORTBOT_EXECUTABLE} #{command} #{arg}"
    child = exec "#{process.env.SUPPORTBOT_EXECUTABLE} #{command} #{arg}", (error, stdout, stderr) ->
            msg.send stdout

# Join the info with <SPACE>
joinInfo = (info) ->
    trimmed = (item.replace /^\s+|\s+$/g, "" for item in info)
    trimmed = (item for item in trimmed when item.length > 0)

    if trimmed.length > 0
        whole = trimmed.join "<SPACE>"
        whole = addslashes whole
        "\"#{whole}\""
    else 
        trimmed.join ""
    
# Is supportbot enabled for this bot?
supportBotEnabled = () ->
    unless process.env.SUPPORTBOT_ENABLED == 'true'
        false
    true

# Not escaping single quotes here!
addslashes = (string) ->
  string.replace(/\\/g, "\\\\").replace(/\u0008/g, "\\b").replace(/\t/g, "\\t").replace(/\n/g, "\\n").replace(/\f/g, "\\f").replace(/\r/g, "\\r").replace /"/g, "\\\""




