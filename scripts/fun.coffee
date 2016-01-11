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
#   hubot capitalidea - great idea!
#   hubot thebestgifever - just ask FOWLER
#   hubot bishop - Diffs cat
#   hubot tomcatwaits - Caseys cat

_ = require "underscore"

module.exports = (robot) ->
  robot.respond /reversenuggets$/i, (msg) ->
    msg.send "http://i.giphy.com/4y1DzwdJcnAfC.gif"

  robot.respond /toiletnuggets$/i, (msg) ->
    msg.send "http://i.giphy.com/NnkNYfMcPcGTS.gif"

  robot.respond /capital(\s)?idea$/i, (msg) ->
    msg.send "http://i.imgur.com/8aVB7x0.png"

  robot.respond /the(\s)?best(\s)?gif(\s)?ever$/i, (msg) ->
    msg.send "http://media4.giphy.com/media/V9qc3Adm2wWyY/giphy.gif"

  robot.respond /bees$/i, (msg) ->
    bees = [
      'http://i.giphy.com/dcubXtnbck0RG.gif',
      'https://media2.giphy.com/media/uclzDwprOogmI/200.gif',
      'https://media0.giphy.com/media/12OQCyR1l6zU76/200.gif',
      'http://i.giphy.com/dcubXtnbck0RG.gif',
      'http://i.giphy.com/dcubXtnbck0RG.gif',
      'http://i.giphy.com/dcubXtnbck0RG.gif',
      'http://i.giphy.com/dcubXtnbck0RG.gif',
      'http://i.giphy.com/dcubXtnbck0RG.gif',
      'http://i.giphy.com/dcubXtnbck0RG.gif',
      'http://i.giphy.com/dcubXtnbck0RG.gif',
      'http://i.giphy.com/dcubXtnbck0RG.gif',
      'http://i.giphy.com/dcubXtnbck0RG.gif',
      'http://i.giphy.com/dcubXtnbck0RG.gif',
      'http://i.giphy.com/dcubXtnbck0RG.gif',
      'https://media.giphy.com/media/RnAorGjnsUkwg/giphy.gif',
      'https://media.giphy.com/media/iJxPqw5mNXuAo/giphy.gif',
      'http://i.giphy.com/dcubXtnbck0RG.gif',
      'https://media.giphy.com/media/FphE0L24UycIU/giphy.gif',
      'http://i.giphy.com/dcubXtnbck0RG.gif',
      'https://media.giphy.com/media/YPjFIgSccMHS0/giphy.gif'
    ]
    msg.send msg.random bees

  robot.respond /tomcat(\s)?waits$/i, (msg) ->
    tomcatwaits = [
      'http://i.imgur.com/oeoaDgi.jpg',
      'http://i.imgur.com/GNRmzsf.jpg',
      'http://i.imgur.com/mg5QDd5.jpg',
      'http://i.imgur.com/TLIilpN.jpg',
      'http://i.imgur.com/lAj58Lt.jpg',
      'http://i.imgur.com/nLso2PL.jpg'
    ]
    msg.send msg.random tomcatwaits

  robot.respond /bishop$/i, (msg) ->
    tehbishop = [
      'https://www.dropbox.com/s/uxy0wxomh49wqmy/2015-10-27%2016.13.43.jpg',
      'https://www.dropbox.com/s/rh79uce5ijtrwpk/2015-10-21%2015.01.08.jpg',
      'https://dl.dropboxusercontent.com/u/2103751/gifs/hamper.gif',
      'https://www.dropbox.com/s/08dqb3aiov0vdon/2015-09-29%2022.02.43.jpg',
      'https://www.dropbox.com/s/09sxpi86gf8pbb6/2015-09-07%2016.45.33.jpg',
      'https://www.dropbox.com/s/l64nsd3fe8s7npx/2012-07-04%2008.31.41.jpg',
      'https://www.dropbox.com/s/7ox0nbh87u1av71/2012-06-09%2022.07.32.jpg',
      'https://www.dropbox.com/s/03bgyz6xskawd51/2012-08-12%2015.48.25.jpg',
      'https://www.dropbox.com/s/ll1cjgsye9axer2/2012-10-07%2021.03.44.jpg',
      'https://www.dropbox.com/s/6mywrdlrcr6z3j7/2012-11-18%2008.14.27.jpg',
      'https://www.dropbox.com/s/wavf29wcek59d8r/2013-01-07%2019.24.13.jpg',
      'https://www.dropbox.com/s/i02bf249cuxj40b/2013-01-17%2020.10.34.jpg',
      'https://www.dropbox.com/s/4gpdz0loeaizibr/2013-02-09%2009.58.36.jpg',
      'https://www.dropbox.com/s/n0y31hm4ou8tc5v/2013-02-23%2009.50.17.jpg',
      'https://www.dropbox.com/s/jmu8mv98k3rjy9t/2013-02-13%2021.54.40.jpg',
      'https://www.dropbox.com/s/w1wc00rxvodi2h5/2013-03-02%2009.46.34.jpg',
      'https://www.dropbox.com/s/2giyr37i8idc18z/2013-03-29%2013.15.09.jpg',
      'https://www.dropbox.com/s/a8ilhj5jz52au6g/2013-03-30%2010.23.30.jpg',
      'https://www.dropbox.com/s/vx9mpmvxjphoc7w/2013-04-06%2010.18.24.jpg',
      'https://www.dropbox.com/s/wbcvxwpkfcs93gq/2013-05-10%2008.29.41.jpg',
      'https://www.dropbox.com/s/av3ctsbf4lwer7a/2013-06-20%2021.38.16.jpg',
      'https://www.dropbox.com/s/wxsgs293fae7fa8/2013-07-20%2009.49.50.jpg',
      'https://www.dropbox.com/s/hzohsqtyzonuo15/2013-07-27%2010.34.32.jpg',
      'https://www.dropbox.com/s/bee7f1qmfolqxoe/2013-08-04%2021.04.21.jpg',
      'https://www.dropbox.com/s/70x25ouumegdui3/2013-08-16%2019.35.50.jpg',
      'https://www.dropbox.com/s/yl7gcgpzci0m6k0/2013-08-20%2020.12.40.jpg',
      'https://www.dropbox.com/s/bmm9k7orontflhv/2013-08-28%2018.40.45.jpg',
      'https://www.dropbox.com/s/i8eophms51aao6p/2013-10-30%2010.18.17.jpg',
      'https://www.dropbox.com/s/og2p15shehncr2i/2013-11-16%2018.16.33-1.jpg',
      'https://www.dropbox.com/s/n6kii0ibp6dw5js/2013-11-25%2020.31.27-2.jpg',
      'https://www.dropbox.com/s/pgzbe24sf7nkm1y/2013-11-30%2011.05.30.jpg',
      'https://www.dropbox.com/s/fn10fzbqkbcycf0/2013-12-07%2009.44.22.jpg',
      'https://www.dropbox.com/s/oluhz4fk4mma4rr/2013-12-10%2014.37.35.jpg',
      'https://www.dropbox.com/s/4vh1e5elgq44x5g/2014-03-19%2022.16.31.jpg',
      'https://www.dropbox.com/s/qvk52njyr95v1e9/2014-05-25%2010.29.28.jpg',
      'https://www.dropbox.com/s/4n0elm547lxakpm/2014-06-28%2009.41.02-2.jpg',
      'https://www.dropbox.com/s/apzmqecaxrightd/2014-08-27%2017.19.09.jpg',
      'https://www.dropbox.com/s/al13yzk95y0957r/2014-09-04%2020.56.57.jpg',
      'https://www.dropbox.com/s/dn3osuei2t4u550/2014-10-05%2020.48.30.jpg',
      'https://www.dropbox.com/s/zr4hyaemxq9tzc3/2014-11-02%2022.14.04.jpg',
      'https://www.dropbox.com/s/j21di6rjxjhjhe9/2015-05-31%2009.55.24.jpg',
      'https://www.dropbox.com/s/sbuty386e22eh85/2015-06-07%2018.13.08-1.jpg',
      'https://www.dropbox.com/s/65ybqq789suz9lr/2015-06-28%2017.43.48-2.jpg',
      'https://www.dropbox.com/s/86as24j74sk44ud/2015-07-26%2019.05.02.jpg',
      'https://www.dropbox.com/s/vg32uup6u5dmo54/2015-08-21%2015.19.31.jpg',
      'https://www.dropbox.com/s/wyyp1argl8a6ck0/2015-09-07%2016.44.03.jpg',
      'https://www.dropbox.com/s/sbuty386e22eh85/2015-06-07%2018.13.08-1.jpg'
    ]
    msg.send msg.random tehbishop

  robot.respond /caleb$/i, (msg) ->
    calebapple = [
      'https://hipchat.dev.pardot.com/files/1/209/3pfm0Zx6Yt6Nc7c/calebapple.gif'
    ]
    msg.send msg.random calebapple

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
      "#{target} is on FIRE! Oh my!",
      "Watch #{target} whip! Now watch #{target} nae nae!",
      "Go #{target}! It's your birthday!",
      "#{target} is on fleek",
      "#{target} is streets ahead!",
      "#{target} is bonafide"
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
      'http://i.imgur.com/IJPBxgn.gif',
      'http://media4.giphy.com/media/ZRdoRaKVvfGHm/giphy.gif',
      'https://www.youtube.com/watch?v=8ZCysBT5Kec',
      'https://media.giphy.com/media/EGyW8qwza7ByE/giphy.gif',
      'https://media.giphy.com/media/vBxc7PxxWAv9S/giphy.gif',
      'https://media.giphy.com/media/sEVisqKC04Wek/giphy.gif',
      'https://media.giphy.com/media/snEeOh54kCFxe/giphy.gif',
      'https://media.giphy.com/media/KmTnUKop0AfFm/giphy.gif',
      'https://media.giphy.com/media/lNMyVfxjfzIJO/giphy.gif',
      'https://media.giphy.com/media/fJXB7Qjzu9pQc/giphy.gif',
      'https://media.giphy.com/media/qxqXS7PhBWgWk/giphy.gif',
      'https://www.youtube.com/watch?v=QCniMXdbO6c',
      'https://www.youtube.com/watch?v=JYc05gZFly0',
      'https://www.youtube.com/watch?v=NsICCjOQ3Dg',
      'https://i.imgur.com/KZf5kWZ.png'
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
      "https://hipchat.dev.pardot.com/files/1/139/p2nyPWIpuRJsELg/Screen%20Shot%202015-11-13%20at%203.34.37%20PM.png",
      "https://hipchat.dev.pardot.com/files/1/65/sWAGNmuFsb4TOjt/Kyle%20Gets%20Weird.gif"
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
      Me msg, "kawaii", (url) ->
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
#    msg.http('http://ajax.googleapis.com/ajax/services/search/images')
#    .query(v: "1.0", rsz: '8', q: query)
#    .get() (err, res, body) ->
#      images = JSON.parse(body)
#      images = images.responseData.results
#      image  = msg.random images
#      cb "#{image.unescapedUrl}"
# Using deprecated Google image search API
#imageMe = (msg, query, animated, faces, cb) ->
#    cb = animated if typeof animated == 'function'
#    cb = faces if typeof faces == 'function'
    googleCseId = "006277482686057757140:iilj71y0d0u" #<-- free, 100searches a day
    if googleCseId
  # Using Google Custom Search API
      googleApiKey = "AIzaSyCb72sJ7O8wqZC77RCXIbUM72iPKo1eFgw" #<-- free, 100searches a day
      if !googleApiKey
        msg.robot.logger.error "Missing environment variable HUBOT_GOOGLE_CSE_KEY"
        msg.send "Missing server environment variable HUBOT_GOOGLE_CSE_KEY."
        return
      q =
        q: query,
        searchType:'image',
        safe:'high',
        fields:'items(link)',
        cx: googleCseId,
        key: googleApiKey
#      if animated is true
#        q.fileType = 'gif'
#        q.hq = 'animated'
#      if faces is true
#        q.imgType = 'face'
      url = 'https://www.googleapis.com/customsearch/v1'
      msg.http(url)
      .query(q)
      .get() (err, res, body) ->
        if err
          msg.send "Encountered an error :( #{err}"
          return
        if res.statusCode isnt 200
          msg.send "Bad HTTP response :( #{res.statusCode}"
          return
        response = JSON.parse(body)
        if response?.items
          image = msg.random response.items
          cb ensureImageExtension image.link
        else
          msg.send "Oops. I had trouble searching '#{query}'. Try later."
          ((error) ->
            msg.robot.logger.error error.message
            msg.robot.logger
            .error "(see #{error.extendedHelp})" if error.extendedHelp
          ) error for error in response.error.errors if response.error?.errors
    else
  # Using deprecated Google image search API
      q = v: '1.0', rsz: '8', q: query, safe: 'active'
#      q.imgtype = 'animated' if typeof animated is 'boolean' and animated is true
#      q.imgtype = 'face' if typeof faces is 'boolean' and faces is true
      msg.http('https://ajax.googleapis.com/ajax/services/search/images')
      .query(q)
      .get() (err, res, body) ->
        if err
          msg.send "Encountered an error :( #{err}"
          return
        if res.statusCode isnt 200
          msg.send "Bad HTTP response :( #{res.statusCode}"
          return
        images = JSON.parse(body)
        images = images.responseData?.results
        if images?.length > 0
          image = msg.random images
          cb ensureImageExtension image.unescapedUrl
        else
          msg.send "Sorry, I found no results for '#{query}'\n\n [Response: #{body}]."

  ensureImageExtension = (url) ->
    ext = url.split('.').pop()
    if /(png|jpe?g|gif)/i.test(ext)
      url
    else
      "#{url}#.png"
