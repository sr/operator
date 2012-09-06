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

sys = require "sys"
exec = require('child_process').exec;

module.exports = (robot) ->
    # Add new ticket
    robot.hear /^!add\s+(.*)/i, (msg) ->
        info = joinInfo msg.match[1].split " "

        sendSupportCommand "addTicket #{msg.message.user.name}", info

    # Add more to a ticket
    robot.hear /^!(\d+)\s+(.*)$/i, (msg) ->
        ticket = msg.match[1].split " "
        info = joinInfo msg.match[2].split " "

        sendSupportCommand "addMoreToTicket #{ticket}", info + " #{msg.message.user.name}"

    # Close a ticket
    robot.hear /^!close\s+(\d+)\s*(.*)$/i, (msg) ->
        ticket = msg.match[1].split " "
        info = joinInfo msg.match[2].split " "

        sendSupportCommand "closeTicket #{ticket}", "#{msg.message.user.name} #{info}"

sendSupportCommand = (command, arg) ->
    child = exec "#{process.env.SUPPORTBOT_EXECUTABLE} #{command} #{arg}", (error, stdout, stderr) ->
            sys.print('stdout: ' + stdout);
            sys.print('stderr: ' + stderr);
            
            console.log 'exec error: ' + error

    console.log process.env.SUPPORTBOT_EXECUTABLE + " #{command} #{arg}"

joinInfo = (info) ->
    trimmed = (item.replace /^\s+|\s+$/g, "" for item in info)
    trimmed = (item for item in trimmed when item.length > 0)

    if trimmed.length > 0
        trimmed.join "<SPACE>"
    else 
        trimmed.join ""




