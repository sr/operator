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
#   hubot toiletnuggets - Get rid of some nuggets
#   hubot reversenuggets - Get nuggets
#   hubot puppies - Get puppies
#   hubot beyonce - Get charisma
#   hubot visualstudio - Get lawlz
#   hubot waffles - Get waffles
#   hubot chikin - Get chicken noises
#   hubot headdesk - Get headdesk.gif
#   hubot hater - They gonna hate
#   hubot panic - PANIC!1!1!!!
#   hubot jarsh - jarsh
#   hubot kyle - kyle
#   hubot makeitrain - make it rain
#   hubot blame <person> - Objectively make it THEIR fault
#   hubot praise <person> - Objectively make it THEIR win!
#   hubot miniTinny - Get Tiny Tinny
#   hubot tbone - Get Tuberculosis. Once.
#   hubot bestfriends - Get Friends
#   hubot its happening - Get Ron Paul
#   hubot situation - Belinda Wong Situation
#   hubot engage - . M A K E . I T . S O .
#   hubot picard - for when you're feeling frisky!
#   hubot visualstudio - you_irl (if you were a M$ dev)
#   hubot nope - Got nope?
#   hubot tldr - Totally didn't read it
#   hubot tl;dr - Totally didn't read it
#   hubot dickbutt (me) - Get what you think you're gonna get
#   hubot chatty (me) - Got chatty?
#   hubot doge (me) - Such wow
#   hubot doge bomb <count> - Many awesome
#   hubot corgi (me) - It's dangerous to go alone. Take this.
#   hubot corgi bomb <count> - It's dangerous to go alone. Take these.
#   hubot knightrider (me) - Only the best
#   hubot knightrider bomb <count> - Lots of the best
#   hubot hasselhoff (me) - Cant get enough of that chest hair
#   hubot hasselhoff bomb <count> - ..Okay, I think we've got enough chest hair now...
#   hubot macgyver (me) - MULLET ME
#   hubot macgyver bomb <count> - MULLET ME GOOOOOD
#   hubot busey (me) - Winners do what losers dont want to do
#   hubot busey bomb <count> - If you take shortcuts you get cut short
#   hubot niccage (me) - I know what it's like to meet someone you admire and have them be a complete jerk.
#   hubot niccage bomb <count> - I do enjoy animated movies. I really love anime and movies like 'Spirited Away' and 'Howl's Moving Castle.'
#   hubot totally not nic cage - ...Or is it?
#   hubot kawaii (me) - so cute it hurts
#   hubot kawaii bomb <count> - OMFG THIS IS SO KAWAII DESU
#   hubot meme (me) - You want it? You got it
#   hubot dankmeme (me) - Synonymous with dank: sick, ill, boss, dope, fly
#   hubot winning - You're just jelly.
#   hubot magicword - Nuh uh uhhh!

_ = require "underscore"

module.exports = (robot) ->
  robot.respond /reversenuggets$/i, (msg) ->
    msg.send "http://i.giphy.com/4y1DzwdJcnAfC.gif"

  robot.respond /toiletnuggets$/i, (msg) ->
    msg.send "http://i.giphy.com/NnkNYfMcPcGTS.gif"

  robot.respond /bees$/i, (msg) ->
    msg.send "http://i.giphy.com/dcubXtnbck0RG.gif"

  robot.respond /beyonce$/i, (msg) ->
    charisma = [
      'http://lisafrankpoetry.files.wordpress.com/2012/07/kittens.gif',
      'http://static.rookiemag.com/2012/08/1346168144lisafrankfolder.jpg',
      'http://cdn.volcom.com/wordpress/wp-content/uploads/2013/09/Unknown1.jpeg',
      'http://fashiongrunge.files.wordpress.com/2012/05/tumblr_m0kuc045mq1qb67y3.jpeg',
      'http://thetangential.com/wp-content/uploads/2011/03/lisafrank1.jpg',
      'http://i208.photobucket.com/albums/bb213/pairsofreckles/polar_bear.jpg'
    ]
    msg.send msg.random charisma

  robot.respond /puppies$/i, (msg) ->
    msg.send "http://i.imgur.com/lSwAPqr.gif"

  robot.respond /shades$/i, (msg) ->
    msg.send "http://i.imgur.com/yXAJ3Uw.gif"

  robot.respond /picard$/i, (msg) ->
    msg.send "http://i.imgur.com/IgxL0lR.gif"

  robot.respond /visualstudio$/i, (msg) ->
    msg.send "https://hipchat.dev.pardot.com/files/1/204/tpEHzIVPqzNKIDM/upload.png"

  robot.respond /magicword$/i, (msg) ->
    msg.send "http://i.imgur.com/Ryv8YVP.gif"

  robot.respond /waffles$/i, (msg) ->
    msg.send "http://i.imgur.com/8TkPJcP.gif"

  robot.respond /blame\s+(.*)$/i, (msg) ->
    target = msg.match[1]

    blames = [
      "#{target} is responsible!",
      "#{target} makes questionable decisions",
      "#{target} breaks most things around here",
      "#{target} caused the current problem",
      "#{target} did it!",
      "#{target} has no idea what they are doing, but we still like 'em :)",
      "(scumbag) #{target} *so* did that :-/"
    ]

    msg.send msg.random blames

  robot.respond /praise\s+(.*)$/i, (msg) ->
    target = msg.match[1]

    compliments = [
      "#{target} is a pillar of virtue",
      "#{target} has swagger for days",
      "Let the word go forth from this time and place, that #{target} will be known as a winner.",
      "#{target}, you are my hero",
      "All good work done shall bear #{target}'s name. So let it be written, so it shall be done.",
      "Today, #{target} brought forth in this room a feat of great success, conceived in magnificence, and dedicated to awesomeness.",
      "Today, #{target} suddenly and deliberately kicked some ass",
      "#{target} makes it WERK",
      "#{target} is on FIRE! Oh my!"
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
      'haters gonna hate',
      '(haters)'
    ]
    msg.send msg.random haters

  robot.respond /headdesk$/i, (msg) ->
    msg.send "http://orig12.deviantart.net/5a7b/f/2012/047/6/2/head_desk_by_catmaniac8x-d4pz9ps.gif"

  robot.respond /panic$/i, (msg) ->
    panics = [
      'oh shit oh shit oh shit oh shit oh shit',
      'Egads, I just pooped myself!',
      'http://media.giphy.com/media/dbtDDSvWErdf2/giphy.gif',
      'https://media.giphy.com/media/KqWzEMydtRHX2/giphy.gif',
      'http://i.imgur.com/IJPBxgn.gif'
    ]

    msg.send msg.random panics

  robot.respond /engage$/i, (msg) ->
    engages = [
      'http://i.imgur.com/kSUHUU7.gif',
      'http://i.imgur.com/MX458aQ.jpg',
      'http://i.imgur.com/s4kO6Zj.gif',
      'http://i.imgur.com/GfzcTu0.gif',
      'http://i.imgur.com/utFIfjv.gif',
      'http://i.imgur.com/pjEU3Fo.gif',
      'http://i.imgur.com/Y6PRvR3.gif',
      'http://i.imgur.com/KQujX2P.gif',
      'http://i.imgur.com/JuA0Ts4.gif',
      'http://i.imgur.com/otOwD1Q.gif',
      'http://i.imgur.com/O0t44wR.gif',
      'http://i.imgur.com/bjc4vlo.gif',
      'http://i.imgur.com/yEyw4FU.gif',
      'http://i.imgur.com/HgjO87I.gif',
      'http://i.imgur.com/QJvY45C.gif',
      'http://i.imgur.com/gGDcx0W.gif',
      'http://i.imgur.com/R0ZVqSo.gif',
      'http://i.imgur.com/4LWaG0a.gif',
      'http://i.imgur.com/e2WJpvI.gif'
    ]
    msg.send msg.random engages

  robot.respond /jarsh$/i, (msg) ->
    jarshes = [
      'https://hipchat.dev.pardot.com/files/1/168/QH3hjSnULEeFsyc/JarshUpsideDown.jpeg',
      'http://i.imgur.com/1k3GyNf.jpg'
    ]

    msg.send msg.random jarshes

  robot.respond /kyle$/i, (msg) ->
    msg.send msg.random [
      "https://hipchat.dev.pardot.com/files/1/282/eYuVJnFMlUJAqnw/2015-10-15%2016_37_09.gif",
      "https://hipchat.dev.pardot.com/files/1/139/p2nyPWIpuRJsELg/Screen%20Shot%202015-11-13%20at%203.34.37%20PM.png"
    ]

  robot.respond /makeitrain$/i, (msg) ->
    msg.send "https://hipchat.dev.pardot.com/files/1/282/M6ckjWgQX2HM4Ne/2015-11-16%2018_10_12.gif"

  robot.respond /miniTinny$/i, (msg) ->
    miniTinnies = [
      "https://hipchat.dev.pardot.com/files/1/168/bsimEJhT7jZCY9w/Tinny.jpg"
    ]

    msg.send msg.random miniTinnies

  robot.respond /tbone$/i, (msg) ->
    tbones = [
      "https://hipchat.dev.pardot.com/files/1/42/ttSs2Ol0zENJGq0/TBone.jpeg"
    ]

    msg.send msg.random tbones


  robot.respond /bestfriends$/i, (msg) ->
    bestfriendss = [
      "https://hipchat.dev.pardot.com/files/1/22/MO21rCEkbDsiomt/phoobs.gif"
    ]

    msg.send msg.random bestfriendss


  robot.respond /it\'?s\shappening$/i, (msg) ->
    msg.send "http://i.kinja-img.com/gawker-media/image/upload/19c35oidyf35igif.gif"


  robot.respond /situation$/i, (msg) ->
    msg.send "https://hipchat.dev.pardot.com/files/1/39/VW6iFJhRbY0AYVy/belinda_situation.jpg"


  robot.respond /nope$/i, (msg) ->
    msg.send "http://media.giphy.com/media/b4pPnoO1QDd1C/giphy.gif"

  robot.respond /(tldr|tl;dr)$/i, (msg) ->
    TLDRS=[
      'http://media4.giphy.com/media/EeIzKI0uDz916/giphy.gif',
      'http://media2.giphy.com/media/YOvJuai8jPGpO/giphy.gif',
      'http://media4.giphy.com/media/ToMjGpqWojvqz7ts2li/giphy.gif',
      'http://media3.giphy.com/media/lcmYVxHTvkOLC/giphy.gif'
    ]
    msg.send msg.random TLDRS

  robot.hear /over 9000$/i, (msg) ->
    msg.send 'http://24.media.tumblr.com/tumblr_lwhv2roIab1qd47jqo1_500.gif#.png'

  robot.hear /knowing is half the battle$/i, (msg) ->
    msg.send 'http://i.imgur.com/0HMzzBB.png'

  robot.respond /dickbutt(\sme)?$/i, (msg) ->
    imageMe msg, "dickbutt", (url) ->
      msg.send "#{url}"

  robot.respond /chatty(\sme)?$/i, (msg) ->
    imageMe msg, "chatty salesforce", (url) ->
      msg.send "#{url}"

  robot.respond /doge(\sme)?$/i, (msg) ->
    imageMe msg, "doge", (url) ->
      msg.send "#{url}"

  robot.respond /doge bomb( (\d+))?$/i, (msg) ->
    count = msg.match[2] || 3
    for i in [1..count]
      imageMe msg, "doge", (url) ->
        msg.send "#{url}"

  robot.respond /knightrider(\sme)?$/i, (msg) ->
    imageMe msg, "knight rider", (url) ->
      msg.send "#{url}"

  robot.respond /knightrider bomb( (\d+))?$/i, (msg) ->
    count = msg.match[2] || 3
    for i in [1..count]
      imageMe msg, "knight rider", (url) ->
        msg.send "#{url}"

  robot.respond /hasselhoff(\sme)?$/i, (msg) ->
    imageMe msg, "hasselhoff", (url) ->
      msg.send "#{url}"

  robot.respond /hasselhoff bomb( (\d+))?$/i, (msg) ->
    count = msg.match[2] || 3
    for i in [1..count]
      imageMe msg, "hasselhoff", (url) ->
        msg.send "#{url}"

  robot.respond /macgyver(\sme)?$/i, (msg) ->
    imageMe msg, "MacGyver", (url) ->
      msg.send "#{url}"

  robot.respond /macgyver bomb( (\d+))?$/i, (msg) ->
    count = msg.match[2] || 3
    for i in [1..count]
      imageMe msg, "MacGyver", (url) ->
        msg.send "#{url}"

  robot.respond /busey(\sme)?$/i, (msg) ->
    imageMe msg, "Gary Busey", (url) ->
      msg.send "#{url}"

  robot.respond /busey bomb( (\d+))?$/i, (msg) ->
    count = msg.match[2] || 3
    for i in [1..count]
      imageMe msg, "Gary Busey", (url) ->
        msg.send "#{url}"

  robot.respond /niccage(\sme)?$/i, (msg) ->
    imageMe msg, "Nicolas Cage", (url) ->
      msg.send "#{url}"

  robot.respond /niccage bomb( (\d+))?$/i, (msg) ->
    count = msg.match[2] || 3
    for i in [1..count]
      imageMe msg, "Nicolas Cage", (url) ->
        msg.send "#{url}"

  robot.respond /totally\s+not\s+nic\s+cage$/i, (msg) ->
    imageMe msg, "Nicolas Cage as everyone", (url) ->
      msg.send "#{url}"

  robot.respond /kawaii(\sme)?$/i, (msg) ->
    imageMe msg, "kawaii", (url) ->
      msg.send "#{url}"

  robot.respond /kawaii bomb( (\d+))?$/i, (msg) ->
    count = msg.match[2] || 3
    for i in [1..count]
      imageMe msg, "kawaii", (url) ->
        msg.send "#{url}"

  robot.respond /corgi(\sme)?$/i, (msg) ->
    imageMe msg, "corgi", (url) ->
      msg.send "#{url}"

  robot.respond /corgi bomb( (\d+))?$/i, (msg) ->
    count = msg.match[2] || 3
    for i in [1..count]
      imageMe msg, "corgi", (url) ->
        msg.send "#{url}"

  robot.respond /meme(\sme)?$/i, (msg) ->
    imageMe msg, "meme", (url) ->
      msg.send "#{url}"

  robot.respond /dankmeme(\sme)?$/i, (msg) ->
    imageMe msg, "dank meme", (url) ->
      msg.send "#{url}"

  robot.respond /winning$/i, (msg) ->
    imageMe msg, "Charlie Sheen winning", (url) ->
      msg.send "#{url}"

  imageMe = (msg, query, cb) ->
    msg.http('http://ajax.googleapis.com/ajax/services/search/images')
    .query(v: "1.0", rsz: '8', q: query)
    .get() (err, res, body) ->
      images = JSON.parse(body)
      images = images.responseData.results
      image  = msg.random images
      cb "#{image.unescapedUrl}"
