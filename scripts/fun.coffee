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
        msg.send "https://s3.amazonaws.com/uploads.hipchat.com/45727/306030/e3Xgb1wrgi4vDVF/26871.gif"

    robot.hear /^!toiletnuggets$/i, (msg) ->
        msg.send "http://1-ps.googleusercontent.com/x/www.dailydawdle.com/images.dailydawdle.com/how-to-flush-56-nuggets.gif.pagespeed.ce.xFOeLk3OWO.gif"

    robot.hear /^!beyonce/i, (msg) ->
        charisma = [
            "http://lisafrankpoetry.files.wordpress.com/2012/07/kittens.gif",
            "http://static.rookiemag.com/2012/08/1346168144lisafrankfolder.jpg",
            "http://cdn.volcom.com/wordpress/wp-content/uploads/2013/09/Unknown1.jpeg",
            "http://fashiongrunge.files.wordpress.com/2012/05/tumblr_m0kuc045mq1qb67y3.jpeg",
            "http://thetangential.com/wp-content/uploads/2011/03/lisafrank1.jpg",
            "http://i208.photobucket.com/albums/bb213/pairsofreckles/polar_bear.jpg"
        ]
        msg.send msg.random charisma

    robot.hear /^!puppies/i, (msg) ->
        msg.send "http://i.imgur.com/lSwAPqr.gif"

    milkshake  = "https://s3.amazonaws.com/uploads.hipchat.com/45727/306033/0ExRFQY3vttdRGE/output.gif"
    funnelcake = "https://s3.amazonaws.com/uploads.hipchat.com/45727/306033/QByVSFk2ZCG7upz/output.gif"
    beerfest   = "https://s3.amazonaws.com/uploads.hipchat.com/45727/306033/KSFuqD31hX27b0J/output.gif"
    beerfest2  = "https://s3.amazonaws.com/uploads.hipchat.com/45727/306025/2CIbNrI4X0AEkMl/2013-10-04%2020.09.20.jpg"
    shades     = "http://i.imgur.com/yXAJ3Uw.gif"
    robot.hear /!funnelcake/i, (msg) ->
        msg.send funnelcake
    robot.hear /!milkshake/i, (msg) ->
        msg.send milkshake
    robot.hear /!stokesbeer/i, (msg) ->
        msg.send beerfest
    robot.hear /!shades/i, (msg) ->
        msg.send shades
    robot.hear /!stokes$/i, (msg) ->
        msg.send msg.random [milkshake, funnelcake, beerfest, beerfest2, shades]

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
        random = Math.floor(Math.random() * 100)
        if random > 0 and random < 33
            msg.send 'https://s3.amazonaws.com/uploads.hipchat.com/45727/306061/fo3AfbSS5Mvv3kP/sassy.png'
        else if random >= 33 and random < 66
            msg.send 'https://s3.amazonaws.com/uploads.hipchat.com/45727/341003/mjQmdzG1n3jd77P/Saasy%20Atlanta%20Takeover.jpg'
        else
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

    # poop
    robot.hear /^!greyskull$/i, (msg) ->
        msg.send "http://www.andymangels.com/HeMan_DVD_Web/SheRa-S1V1-l.jpg"

    # Get some random nickname
    robot.hear /^!random$/i, (msg) ->
        util.getUsersInRoom msg, (users) ->
            users = util.shuffle users

            while users[0].jid is util.getBotUser()
                users = util.shuffle users


            msg.send "I choose @#{users[0].mention_name}"

    # your mom, hahahaha
    robot.hear /^!yourmom$/i, (msg) ->
        msg.send "http://dl.dropboxusercontent.com/u/45215568/internbot/yourmom4.jpeg"

    robot.hear /it\'?s\shappening/i, (msg) ->
        msg.send "http://i.kinja-img.com/gawker-media/image/upload/19c35oidyf35igif.gif"

    robot.hear /top\smen/i, (msg) ->
        msg.send "http://static3.wikia.nocookie.net/__cb20070924225034/indianajones/images/1/1a/Eaton.jpg"

    robot.hear /^!kyle$/i, (msg) ->
        msg.send "https://s3.amazonaws.com/uploads.hipchat.com/45727/306033/D6SQIZKD7rsl5ut/output1.gif"

