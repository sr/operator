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

module.exports = (robot) ->
  robot.respond /reversenuggets$/i, (msg) ->
    msg.send "http://i.imgur.com/7Ljw6Gg.gif"

  robot.respond /toiletnuggets$/i, (msg) ->
    msg.send "http://i.imgur.com/LUi0ncH.gif"

  robot.respond /beyonce/i, (msg) ->
    charisma = [
      "http://lisafrankpoetry.files.wordpress.com/2012/07/kittens.gif",
      "http://static.rookiemag.com/2012/08/1346168144lisafrankfolder.jpg",
      "http://cdn.volcom.com/wordpress/wp-content/uploads/2013/09/Unknown1.jpeg",
      "http://fashiongrunge.files.wordpress.com/2012/05/tumblr_m0kuc045mq1qb67y3.jpeg",
      "http://thetangential.com/wp-content/uploads/2011/03/lisafrank1.jpg",
      "http://i208.photobucket.com/albums/bb213/pairsofreckles/polar_bear.jpg"
    ]
    msg.send msg.random charisma

  robot.respond /puppies/i, (msg) ->
    msg.send "http://i.imgur.com/lSwAPqr.gif"

  robot.respond /shades/i, (msg) ->
    msg.send "http://i.imgur.com/yXAJ3Uw.gif"

  robot.respond /waffles/i, (msg) ->
    msg.send "http://i.imgur.com/8TkPJcP.gif"

  robot.respond /blame\s+(.*)/i, (msg) ->
    target = msg.match[1]

    blames = [
      "#{target} is responsible!",
      "#{target} makes questionable decisions",
      "#{target} breaks most things around here",
      "#{target} caused the current problem",
      "#{target} did it!",
      "#{target} has no idea what they are doing, but we still like 'em :)"
    ]

    msg.send msg.random blames

  robot.respond /praise\s+(.*)/i, (msg) ->
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

  robot.respond /chikin$/i, (msg) ->
    chikins = [
      'bucka bucka bucka BUCKA BUACKA baaaaaaAAAA'
      'cuh-KA cuh-KA cuh-KA KA',
      'AH-coodle-doodle-doo AH-coodle-doodle-doo',
      'chee CHAH chee CHAH chee CHAH',
      'cookoo KATCHA cookoo KATCHA'
    ]

    msg.send msg.random chikins

  robot.respond /hater$/i, (msg) ->
    haters = [
      'haters gonna hate'
    ]
    msg.send msg.random haters

  robot.respond /headdesk$/i, (msg) ->
    msg.send "http://orig12.deviantart.net/5a7b/f/2012/047/6/2/head_desk_by_catmaniac8x-d4pz9ps.gif"

  robot.respond /panic$/i, (msg) ->
    panics = [
      'oh shit oh shit oh shit oh shit oh shit',
      'Egads, I just pooped myself!',
    ]

    msg.send msg.random panics

  robot.respond /jarsh$/i, (msg) ->
    jarshes = [
      "https://hipchat.dev.pardot.com/files/1/168/QH3hjSnULEeFsyc/JarshUpsideDown.jpeg"
    ]

    msg.send msg.random jarshes

  robot.respond /miniTinny$/i, (msg) ->
    miniTinnies = [
      "https://hipchat.dev.pardot.com/files/1/168/bsimEJhT7jZCY9w/Tinny.jpg"
    ]

    msg.send msg.random miniTinnies

  robot.hear /^!tbone$/i, (msg) ->
    tbones = [
      "https://hipchat.dev.pardot.com/files/1/42/ttSs2Ol0zENJGq0/TBone.jpeg"
    ]

    msg.send msg.random tbones


  robot.hear /^!bestfriends$/i, (msg) ->
    bestfriendss = [
      "https://hipchat.dev.pardot.com/files/1/22/MO21rCEkbDsiomt/phoobs.gif"
    ]

    msg.send msg.random bestfriendss


  robot.hear /it\'?s\shappening/i, (msg) ->
    msg.send "http://i.kinja-img.com/gawker-media/image/upload/19c35oidyf35igif.gif"

  robot.hear /top\smen/i, (msg) ->
    msg.send "http://www.mememaker.net/static/images/memes/3247839.jpg"

  robot.respond /engage$/i, (msg) ->
    msg.send "http://i.imgur.com/MX458aQ.jpg"

  robot.respond /oncall$/i, (msg) ->
    msg.send "https://i.imgur.com/mWxLrwF.gif"

  robot.respond /nope$/i, (msg) ->
    msg.send "http://media.giphy.com/media/b4pPnoO1QDd1C/giphy.gif"

  robot.hear /ccccccdluereg.*/i, (msg) ->
    msg.send "hey everybody look at #{msg.message.user.name} and laugh!"
    msg.send "http://i.imgur.com/Q567Ivq.gif"
