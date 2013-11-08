# Description:
#   Fun things to do with bots
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
#
util = require "../lib/util"

module.exports = (robot) ->
    if process.env.BOT_TYPE == 'internbot'
      return

    robot.hear /^!reversenuggets$/i, (msg) ->
        if msg.message.user.jid in ['45727_306025@chat.hipchat.com', '45727_306061@chat.hipchat.com', '45727_306403@chat.hipchat.com']
            msg.send "http://lisafrankpoetry.files.wordpress.com/2012/07/kittens.gif"
            return

        msg.send "https://s3.amazonaws.com/uploads.hipchat.com/45727/306030/e3Xgb1wrgi4vDVF/26871.gif"

    robot.hear /^!toiletnuggets$/i, (msg) ->
        if msg.message.user.jid in ['45727_306025@chat.hipchat.com', '45727_306061@chat.hipchat.com', '45727_306403@chat.hipchat.com']
            msg.send "http://static.rookiemag.com/2012/08/1346168144lisafrankfolder.jpg"
            return

        msg.send "http://1-ps.googleusercontent.com/x/www.dailydawdle.com/images.dailydawdle.com/how-to-flush-56-nuggets.gif.pagespeed.ce.xFOeLk3OWO.gif"

    robot.hear /^!beyonce/i, (msg) ->
        msg.send "http://1-ps.googleusercontent.com/x/www.dailydawdle.com/images.dailydawdle.com/how-to-flush-56-nuggets.gif.pagespeed.ce.xFOeLk3OWO.gif"

    robot.hear /^!puppies/i, (msg) ->
        # if msg.message.user.jid is '45727_470666@chat.hipchat.com'
        #   msg.send "http://1-ps.googleusercontent.com/x/www.dailydawdle.com/images.dailydawdle.com/how-to-flush-56-nuggets.gif.pagespeed.ce.xFOeLk3OWO.gif"
        #   return

        msg.send "http://i.imgur.com/lSwAPqr.gif"

    robot.hear /^!blame\s+(.*)/i, (msg) ->
        target = msg.match[1]

        blames = [
            "#{target} is responsible!",
            "#{target} makes questionable decisions",
            "#{target} breaks most things around here",
            "#{target} caused the current problem",
            "#{target} did it!"
        ]

        msg.send msg.random blames

    robot.hear /^!praise\s+(.*)/i, (msg) ->
        target = msg.match[1]

        compliments = [
            "#{target} is a pillar of virtue",
            "#{target} has swagger for days",
            "Let the word go forth from this time and place, that #{target} will be known as a winner.",
            "#{target}, you are my hero",
            "All good work done shall bear #{target}'s name. So let it be written, so it shall be done.",
            "Today, #{target} brought forth in this room a feat of great success, conceived in magnificence, and dedicated to awesomeness.",
            "Today, #{target} suddenly and deliberately kicked some ass",
            "#{target} makes it WERK"
        ]

        msg.send msg.random compliments

     # Chikins runnin wild
    robot.hear /^!chikin$/i, (msg) ->
        chikins = [
            'bucka bucka bucka BUCKA BUACKA baaaaaaAAAA'
            'cuh-KA cuh-KA cuh-KA KA',
            'AH-coodle-doodle-doo AH-coodle-doodle-doo',
            'chee CHAH chee CHAH chee CHAH',
            'cookoo KATCHA cookoo KATCHA'
        ]

        msg.send msg.random chikins

    # A cow got loose
    robot.hear /^!moo$/i, (msg) ->
        msg.send 'Mooooooo000000000ooooooo000000000ooooooo!!'

    # Hate on someone
    robot.hear /^!hate$/i, (msg) ->
        msg.send 'hate hate hate'

    # Quit hatin
    robot.hear /^!hater$/i, (msg) ->
        msg.send 'haters gonna hate'

    # Panic
    robot.hear /^!panic$/i, (msg) ->
        msg.send 'oh shit oh shit oh shit oh shit oh shit'

    # Poop on someone
    robot.hear /^!poop\s?(.*)/i, (msg) ->
        target = msg.match[1]
        poops = [
            'plop plop blaaaaaart',
            'plooop',
            'pffffft',
            'ploppity plop plooooop',
            'toot'
        ]

        # Shuffle the poops pls
        poops = util.shuffle poops

        util.getUsersInRoom msg, (users) ->
            users = util.shuffle users

            while users.length > 0 and users[0] is not undefined and users[0].jid is util.getBotUser()
                users = util.shuffle users

            if msg.message.user.jid is '45727_306025@chat.hipchat.com' and target
                users[0].mention_name = target

            msg.send "@#{users[0].mention_name} #{poops[0]}"

    # Get some random nickname
    robot.hear /^!random$/i, (msg) ->
        util.getUsersInRoom msg, (users) ->
            users = util.shuffle users

            while users[0].jid is util.getBotUser()
                users = util.shuffle users


            msg.send "I choose @#{users[0].mention_name}"
