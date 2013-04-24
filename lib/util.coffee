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

# Get account information from internal API
module.exports.apiGetAccountInfo = (account_id, msg) ->
    options =
        url: "https://tools.pardot.com/accounts/#{account_id}"
        headers:
            api_key: '1b424ca119675c1c712957531498ac5af4646afb'

    request.get options, (error, response, body) ->
        if error
            console.log 'ERROR'
            console.log error.message
            msg.send "Sorry, unable to fetch info for account ID: #{account_id}"
        else
            # console.log body
            account_info = JSON.parse(body)
            if account_info.error
                msg.send "Sorry, unable to fetch info for account ID: #{account_id}"
            else
                msg.send "Company: #{account_info.company} (#{account_info.id}) | Shard: #{account_info.shard_id}"

module.exports.apiGetAccountsLike = (search_text, msg) ->
    # escaped_text = escape search_text
    escaped_text = encodeURIComponent search_text
    console.log escaped_text
    options =
        url: "https://tools.pardot.com/accounts/like/#{escaped_text}"
        headers:
            api_key: '1b424ca119675c1c712957531498ac5af4646afb'

    request.get options, (error, response, body) ->
        if error
            console.log 'ERROR'
            console.log error.message
            msg.send "Sorry, unable to fetch accounts matching \'#{search_text}\'"
        else
            console.log body
            try
                info_for_accounts = JSON.parse(body)
            catch e
                console.log e
                msg.send "Sorry, unable to fetch accounts matching \'#{search_text}\'"
                return

            if info_for_accounts.error
                msg.send "Sorry, unable to fetch accounts matching \'#{search_text}\'"
            else
                if info_for_accounts.length == 0
                    msg.send "No accounts found that matched \'#{search_text}\'"
                else
                    accounts_to_show = info_for_accounts.length
                    if accounts_to_show > 8
                        msg.send "#{accounts_to_show} accounts matched. Showing the first five."
                        accounts_to_show = 5

                    account_list = ''
                    for account, idx in info_for_accounts
                        if idx >= accounts_to_show
                            break
                        account_list = account_list + "Company: #{account.company} (#{account.id}) | Shard: #{account.shard_id}\n"

                    msg.send account_list
