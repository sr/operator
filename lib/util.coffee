mysql         = require "mysql"
request       = require 'request'
HipChatClient = require "../lib/hipchat"

module.exports.shuffle = (a) ->
  # From the end of the list to the beginning, pick element `i`.
  for i in [a.length-1..1]
    # Choose random element `j` to the front of `i` to swap with.
    j = Math.floor Math.random() * (i + 1)
    # Swap `j` with `i`, using destructured assignment
    [a[i], a[j]] = [a[j], a[i]]
  # Return the shuffled array.
  a

# Get all nicknames for a given message's room
module.exports.getUsersInRoom = (message, callback) ->
  # Check for IRC
  if typeof process.env.HUBOT_IRC_ROOMS is not undefined
    channel = message.robot.adapter.bot.chans[message.message.user.room]
    return [] if not channel
    Object.keys channel.users

  # Connect to the hipchat api
  chatClient = new HipChatClient process.env.HUBOT_HIPCHAT_API_KEY

  # Get all of the users in all chats
  allUsers = message.robot.users()

  # What room id are we in?
  room_jid = message.message.user.reply_to

  ## Need to make an API call to get all of the rooms, then pull the room requested from the list
  ## Then we need to make an api call to get all users in a given room once we have the proper id
  chatClient.listRooms (value) ->
    for room in value.rooms then do (room) =>
      if room.xmpp_jid == room_jid
        # API Call to get the room info
        chatClient.showRoom room.room_id, (room) ->
          userList = []

          # Look through the list of people in the room
          for participant in room.room.participants then do (participant) ->
            userList.push allUsers[participant.user_id]

          callback userList

# Find what room id to post to when a cat comes in
module.exports.getCatRoomId = () ->
    if typeof process.env.HUBOT_IRC_ROOMS is undefined
        process.env.HUBOT_HIPCHAT_ROOMS

    process.env.HUBOT_HIPCHAT_ROOMS

# Get the username of the bot
module.exports.getBotUser = () ->
    if typeof process.env.HUBOT_HIPCHAT_JID is undefined
        process.env.HUBOT_IRC_NICK

    process.env.HUBOT_HIPCHAT_JID


# Get connection to release DB
module.exports.getReleaseDBConn = () ->
    try
        client = mysql.createClient
            user: process.env.DB_USER,
            password: process.env.DB_PASSWORD,
            database: process.env.RELEASE_DATABASE,
            host: '127.0.0.1'

        client
    catch e
        console.log e
        false

# Get connection to quote DB
module.exports.getQuoteDBConn = () ->
    try
        client = mysql.createClient
            user: process.env.DB_USER,
            password: process.env.DB_PASSWORD,
            database: process.env.QUOTE_DATABASE,
            host: '127.0.0.1'

        client
    catch e
        console.log e
        false

# Get connection to kpi DB
module.exports.getKPIDBConn = () ->
    try
        client = mysql.createClient
            user: process.env.DB_USER
            password: process.env.DB_PASSWORD
            database: process.env.KPI_DATABASE,
            host: '127.0.0.1'

        client
    catch e
        console.log e
        false
