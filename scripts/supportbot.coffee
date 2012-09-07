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

        msg.send sendSupportCommand "addTicket #{msg.message.user.name}", info

    # Add more to a ticket
    robot.hear /^!(\d+)\s+(.*)$/i, (msg) ->
        if !supportBotEnabled then return
        ticket = msg.match[1]
        info   = joinInfo msg.match[2].split " "

        msg.send sendSupportCommand "addMoreToTicket #{ticket}", info + " #{msg.message.user.name}"

    # Close a ticket
    robot.hear /^!close\s+(\d+)\s*(.*)$/i, (msg) ->
        if !supportBotEnabled then return
        ticket = msg.match[1]
        info   = joinInfo msg.match[2].split " "

        msg.send sendSupportCommand "closeTicket #{ticket}", "#{msg.message.user.name} #{info}"

    # Open a ticket
    robot.hear /^!open\s+(\d+)$/i, (msg) ->
        if !supportBotEnabled then return
        ticket = msg.match[1]

        msg.send sendSupportCommand "openTicket #{ticket}", "#{msg.message.user.name}"

    # WOC a ticket
    robot.hear /^!woc\s+(\d+)$/i, (msg) ->
        if !supportBotEnabled then return
        ticket = msg.match[1]

        msg.send sendSupportCommand "wocTicket #{ticket}", "#{msg.message.user.name}"

    # Watch a ticket
    robot.hear /^!watch\s+(\d+)$/i, (msg) ->
        if !supportBotEnabled then return
        ticket = msg.match[1]

        sendSupportCommand "ircNotifyTicket", "#{msg.message.user.name} watch #{ticket}"

    # Ignore a ticket
    robot.hear /^!ignore\s+(\d+)$/i, (msg) ->
        if !supportBotEnabled then return
        ticket = msg.match[1]

        msg.send sendSupportCommand "ircNotifyTicket", "#{msg.message.user.name} ignore #{ticket}"

    # What tickets am I watching
    robot.hear /^!watching$/i, (msg) ->
        if !supportBotEnabled then return
        msg.send sendSupportCommand "ircNotifyTicket", "#{msg.message.user.name} info"

    # Overall ticket status
    robot.hear /^!status$/i, (msg) ->
        if !supportBotEnabled then return
        msg.send sendSupportCommand "status", "#{msg.message.user.name}"

    # Specific ticket status
    robot.hear /^!status\s+(\d+)$/i, (msg) ->
        if !supportBotEnabled then return
        ticket = msg.match[1]

        msg.send sendSupportCommand "status", "#{msg.message.user.name} #{ticket}"
        
    # Give a ticket
    robot.hear /^!give\s+(\d+)\s+(.*)$/i, (msg) ->
        if !supportBotEnabled then return
        ticket = msg.match[1]
        user   = msg.match[2]

        users = util.getAllNicks robot

        if users.indexOf user is -1
            msg.send "#{user} does not exist!"
        else
            msg.send sendSupportCommand "assignTicket", "#{ticket} #{user}"

    # Take a ticket
    robot.hear /^!take\s+(\d+)$/i, (msg) ->
        if !supportBotEnabled then return
        ticket = msg.match[1]

        msg.send sendSupportCommand "assignTicket", "#{ticket} #{msg.message.user.name}"

        
# Execute a supportbot task on the terminal
sendSupportCommand = (command, arg) ->
    child = exec "#{process.env.SUPPORTBOT_EXECUTABLE} #{command} #{arg}", (error, stdout, stderr) ->
            sys.print('stdout: ' + stdout);
            sys.print('stderr: ' + stderr);
            
            console.log 'exec error: ' + error

            stdout

# Join the info with <SPACE>
joinInfo = (info) ->
    trimmed = (item.replace /^\s+|\s+$/g, "" for item in info)
    trimmed = (item for item in trimmed when item.length > 0)

    if trimmed.length > 0
        trimmed.join "<SPACE>"
    else 
        trimmed.join ""

# Is supportbot enabled for this bot?
supportBotEnabled = () ->
    unless process.env.SUPPORTBOT_ENABLED == 'true'
        false
    true




