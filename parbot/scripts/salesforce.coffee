# Description:
#   Various Salesforce information
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot helpdesk - Returns the Helpdesk phone number
#   hubot acronyms - Returns a link to all of the Salesforce TLAs
#
# Author:
#   alindeman

module.exports = (robot) ->
  robot.respond /helpdesk$/i, (msg) ->
    msg.reply "Help Desk: 1-415-901-7044 or 1-877-782-2179 (toll-free)"

  robot.respond /acronyms$/i, (msg) ->
    msg.reply "Salesforce TLAs: https://sites.google.com/a/salesforce.com/sfdc-acronyms/acronyms"
