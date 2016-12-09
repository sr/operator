# Description:
#   Fun things to do with bots
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_GOOGLE_CSE_ID
#   HUBOT_GOOGLE_API_KEY
#
# Commands:
#   hubot gif <query> - returns a relevant .gifv to the query
#   hubot aggablagblag - agga blag blag
#   hubot terrifying - Get TV Commercial Hearttrhrob Milana Vayntraub
#   hubot casey - Get casey
#   hubot soon - Get CPJ
#   hubot baller - Get Chappelle. Just saiyan...
#   hubot meeks - Get meeks
#   hubot toiletnuggets - Get rid of some nuggets
#   hubot reversenuggets - Get nuggets
#   hubot bread - developers HATE them! Operations guys find ONE EASY TRICK to write code!
#   hubot puppies - Get puppies
#   hubot beningo - Get beningo classic
#   hubot beningo generator - Get generated beningo cards
#   hubot beyonce - Get charisma
#   hubot waffles - Get waffles
#   hubot chikin - Get chicken noises
#   hubot css - get a css window
#   hubot catbongos - Like, far out, man...
#   hubot cookiecakes - They see me roooolllin'.... They hungryyyyy....
#   hubot headdesk - Get headdesk.gif
#   hubot et - get wasted ET
#   hubot hater - They gonna hate
#   hubot panic - PANIC!1!1!!!
#   hubot elmo - ...elmo
#   hubot jarsh - jarsh
#   hubot rubbs - gifs
#   hubot kyle - kyle
#   hubot nippon - nippon
#   hubot raptorcamp - praise raptors!
#   hubot parker - parker
#   hubot blakem - blakem
#   hubot superkyle - superkyle
#   hubot makeitrain - make it rain
#   hubot excuse (person) - Objectively respond with a classic programming excuse
#   hubot blame <person> - Objectively make it THEIR fault
#   hubot praise <person> - Objectively make it THEIR win!
#   hubot miniTinny - Get Tiny Tinny
#   hubot tbone - Get Tuberculosis. Once.
#   hubot bestfriends - Get Friends
#   hubot its happening - Get Ron Paul
#   hubot master is open - LET'ER RIP
#   hubot situation - Belinda Wong Situation
#   hubot engage - . M A K E . I T . S O .
#   hubot picard - for when you're feeling frisky!
#   hubot visualstudio - you_irl (if you were a M$ dev)
#   hubot nope - Got nope?
#   hubot tldr - Totally didn't read it
#   hubot tl;dr - Totally didn't read it
#   hubot dickbutt (me) - Get what you think you're gonna get
#   hubot chatty (me) - Got chatty?
#   hubot don'ttouchdoge - Don't touch doge!
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
#   hubot mikacat - Brendas cat
#   hubot franciskitty - Katis cat
#   hubot waiting on op to deliver || op || op will deliver || surely op will deliver - 2spoopy4me
#   hubot pingpong - ... ping pong
#   hubot squirrelmaster - behold the master of squirrels
#   hubot dartz - Dartz!!!
#   hubot picklegusta - picklegusta
#   hubot inconceivable - inconceivable!!!
#   hubot bonk - bonks adventure
#   hubot pd - pagerduty phone smash :)
#   hubot rogerroger - What's your vector, Victor? Huh? you have clearance, Clarence. What?
#   hubot abs - ET and BWare
#   hubot pieces - Pieces (and murica!)
#   hubot trolledum8 - rekt
#   hubot rekt - trolledum8
#   hubot gus - Rage GUS!
#   hubot lightning - Rage Lightning!
#   hubot pushit(realgood) - Salt N Peppa 4 Lyfe!
#   hubot lemon - Get's a random image of Lemon
#   hubot sysadmin - Gets random image of sysadmin trading deck
#   hubot securityfail - Gets random image of securityfail
#   hubot cookiecake - Request a cookie cake
#
_ = require "underscore"
cycle = require "../lib/cycle"

module.exports = (robot) ->
  robot.respond /blakem$/i, (msg) ->
    msg.send msg.random [
      "https://hipchat.dev.pardot.com/files/1/64/Jn0SCSfycNWUgpQ/Blake.jpg",
      "https://hipchat.dev.pardot.com/files/1/65/31Iel1Qje2560I0/Blake_braid.jpg",
      "https://hipchat.dev.pardot.com/files/1/65/WnyJW4Q1KyCzZIq/Blake%20road%20work.jpg",
      "https://hipchat.dev.pardot.com/files/1/282/9CAPIYlpbUGdD4H/0e8e6bd1-ae04-4dcb-bbd8-b1d2b0c9aab1.png",
    ]

  robot.respond /cookiecake$/i, (msg) ->
    msg.reply "Great! (cupcake) Submit your request here: https://sfdc.co/cookie-cake"

  robot.respond /gus$/i, (msg) ->
    msg.send "https://hipchat.dev.pardot.com/files/1/252/6jIMiKPvXi17T0l/fuuuuuu_gus.jpg"

  robot.respond /baller$/i, (msg) ->
    msg.send "http://i.imgur.com/zRKUVBS.gifv"

  robot.respond /lemon$/i, (msg) ->
    msg.send "http://i.imgur.com/bMWBLVk.gifv"

  robot.respond /dumpsterfire$/i, (msg) ->
    msg.send "https://hipchat.dev.pardot.com/files/1/162/71ixUc3gH6lnWLC/upload.png"

  robot.respond /doom$/i, (msg) ->
    msg.send "https://hipchat.dev.pardot.com/files/1/190/4t1zZSfsXvPPHl5/doom.gif"

  robot.respond /parker$/i, (msg) ->
    msg.send "https://hipchat.dev.pardot.com/files/1/22/OLA4jR5fndLrjPt/i%27m%20so%20sorry%20parker.gif"

  robot.respond /rekt$/i, (msg) ->
    msg.send "http://media2.giphy.com/media/12kwNiP8SSIUus/giphy.gif"

  robot.respond /trolledum8$/i, (msg) ->
    msg.send "http://media2.giphy.com/media/12kwNiP8SSIUus/giphy.gif"

  robot.respond /soon$/i, (msg) ->
    msg.send "http://assets.sbnation.com/assets/785150/pjsoon-vi.gif"

  robot.respond /raptorcamp$/i, (msg) ->
    msg.send "http://www.mtv.com/news/wp-content/uploads/buzz/2012/12/Ecstasy-Must-Be-Hitting-Bible-Camp.gif"

  robot.respond /picklegusta$/i, (msg) ->
    msg.send "https://hipchat.dev.pardot.com/files/1/62/SmWraho0s2Iyhkf/upload.png"

  robot.respond /terrifying$/i, (msg) ->
    msg.send "http://i.imgur.com/9f8x6MF.gif"

  robot.respond /thumbsup$/i, (msg) ->
    msg.send "https://hipchat.dev.pardot.com/files/1/88/MVcZU1s2CcLTCeS/thumbsup.png"

  robot.respond /catdance$/i, (msg) ->
    msg.send "http://media2.giphy.com/media/8rcikGsC4jED6/giphy.gif"

  robot.respond /rogerroger$/i, (msg) ->
    msg.send "https://www.youtube.com/watch?v=NfDUkR3DOFw&feature=youtu.be&t=55"

  robot.respond /ping(\s)?pong$/i, (msg) ->
    msg.send "https://media.giphy.com/media/4IAzyrhy9rkis/giphy.gif"

  robot.respond /bonk$/i, (msg) ->
    msg.send "http://media4.giphy.com/media/Iel2zZmvUWyf6/giphy.gif"

  robot.respond /inconceivable$/i, (msg) ->
    msg.send "http://i.giphy.com/ohBeIPJ4MEuas.gif"

  robot.respond /beningo$/i, (msg) ->
    msg.send "https://hipchat.dev.pardot.com/files/1/261/ta4Tpwhuc8PCr8L/upload.png"

  robot.respond /beningo(\s)?generator$/i, (msg) ->
    msg.send "http://bit.ly/2ddnlM4"

  robot.respond /cookiecakes$/i, (msg) ->
    msg.send "https://hipchat.dev.pardot.com/files/1/233/RdkTKW0cD8dGQ2e/ezgif.com-add-text.gif"

  robot.respond /elmo$/i, (msg) ->
    msg.send "https://hipchat.dev.pardot.com/files/1/162/YTCOYslSLDAuTGx/ElmoStop.jpg"

  robot.respond /reversenuggets$/i, (msg) ->
    msg.send "http://i.giphy.com/4y1DzwdJcnAfC.gif"

  robot.respond /toiletnuggets$/i, (msg) ->
    msg.send "http://i.giphy.com/NnkNYfMcPcGTS.gif"

  robot.respond /master(\s)?is(\s)?open$/i, (msg) ->
    opens = [
      "https://hipchat.dev.pardot.com/files/1/5/lNYLdAaKwuoNK8I/master_open_4.jpg",
      "https://hipchat.dev.pardot.com/files/1/5/W7PDxo7w6PCeYEd/master_open_2.jpg",
      "https://hipchat.dev.pardot.com/files/1/5/feQJ6xBH72ROnFm/master_open_5.jpg",
      "https://hipchat.dev.pardot.com/files/1/5/kF39KN4eqcehAW9/master_open_1.jpg",
      "https://hipchat.dev.pardot.com/files/1/5/b8dAgHlHnapHPdy/master_open_3.jpg"
    ]
    msg.send msg.random opens

  robot.respond /capital(\s)?idea$/i, (msg) ->
    msg.send "http://i.imgur.com/8aVB7x0.png"

  robot.respond /the(\s)?best(\s)?gif(\s)?ever$/i, (msg) ->
    msg.send "http://media4.giphy.com/media/V9qc3Adm2wWyY/giphy.gif"

  robot.respond /abs$/i, (msg) ->
    msg.send "https://hipchat.dev.pardot.com/files/1%2F62%2FrPK7cHsJFVD7cUr%2FIMG_1642%20%282%29.JPG"

  robot.respond /pieces$/i, (msg) ->
    msg.send msg.random [
      "https://hipchat.dev.pardot.com/files/1/260/YB1QIGT1uFmyaLy/upload.png",
      "https://dl.dropboxusercontent.com/u/2103751/rhys-meme.png"
    ]

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
      'https://media.giphy.com/media/YPjFIgSccMHS0/giphy.gif',
      'https://hipchat.dev.pardot.com/files/1/15/j2gDs5UDFKzGIZ4/bees.gif',
    ]
    msg.send msg.random bees

  robot.respond /srd$/i, (msg) ->
    msg.send "http://i.imgur.com/NZQhi.gif"

  robot.respond /(surely)?(\s)?(waiting)?(\s)?(on)?(\s)?op(\s)?(to)?(\s)?(will)?(\s)?(deliver)?$/i, (msg) ->
    op = [
      'http://i.imgur.com/ndeQyDK.jpg',
      'http://imgur.com/KvS9SCN.jpg',
      'http://i.imgur.com/rLKhdjB.jpg',
      'http://i.imgur.com/QVsCo4c.jpg',
      'http://i.imgur.com/IvvSf6k.jpg',
      'http://i.imgur.com/h2FzYcr.jpg',
      'http://i.imgur.com/6lYZZM6.png',
      'http://i1027.photobucket.com/albums/y333/doomcrusader_photos/op-will-surely-deliver-lets-just-wait.jpg',
      'http://www.quickmeme.com/img/f2/f2094f8ab40fd53d787fd13087c5fb3074bf7be616dee3b970e98b138d2f1b1c.jpg',
      'http://2.bp.blogspot.com/-jfCvSmoNazI/UCFTCnVsKBI/AAAAAAAACN4/UgknohceyVo/s1600/reddit-repost.gif',
      'http://cdn.memegenerator.net/instances/400x/33472244.jpg',
      'http://i.imgur.com/aMTO97c.png',
      'http://i0.kym-cdn.com/photos/images/facebook/000/345/125/92a.png',
      'http://cdn.meme.li/instances/400x/25527349.jpg',
      'http://i.imgur.com/dgH8ht8.png',
      'http://new4.fjcdn.com/pictures/Op_00374b_2061066.jpeg',
      'http://i1.kym-cdn.com/photos/images/facebook/000/592/253/714.jpg',
      'http://i0.kym-cdn.com/photos/images/original/000/160/195/OP-Will-deliver-soon.jpg'
    ]
    msg.send msg.random op

  robot.respond /push(\s)?it(\s)?(real)?(\s)?(good)?$/i, (msg) ->
    pushit = [
      'https://www.youtube.com/watch?v=vCadcBR95oU'
    ]
    msg.send msg.random pushit

  robot.respond /bingo$/i, (msg) ->
    bingo = [
      'https://hipchat.dev.pardot.com/files/1/261/ta4Tpwhuc8PCr8L/upload.png'
    ]
    msg.send msg.random bingo

  robot.respond /nippon$/i, (msg) ->
    nippon = [
      'http://i.imgur.com/T8uvhOu.png'
    ]
    msg.send msg.random nippon

  robot.respond /bread$/i, (msg) ->
    baguette = [
      'http://media3.giphy.com/media/zIZTz4PvRdufu/giphy.gif',
      'http://67.media.tumblr.com/0adc6893d9c300cc7ee0e73a766c4352/tumblr_n5m6o8xHa61tc0bnlo1_500.gif',
      'http://66.media.tumblr.com/33730c5150e513d7cd5334d80571b6da/tumblr_n6bufgdukL1tc0bnlo1_400.gif',
      'http://67.media.tumblr.com/b3b17c4e74ebb950e7f6a7d469efc5fa/tumblr_ngd7ta86HM1tc0bnlo1_500.gif',
      'http://66.media.tumblr.com/2bd775e0c4afa8cf6e89d0824512785f/tumblr_n64avs5LEd1tc0bnlo1_500.gif',
      'http://66.media.tumblr.com/e76f8f3cb39a2cf8b0a401d6575aad9a/tumblr_n5tp10UbeE1tc0bnlo1_500.gif',
      'http://66.media.tumblr.com/623a9bec56d41b46a81087a79eb3249c/tumblr_n5rkv3kyLU1tc0bnlo1_500.gif',
      'http://66.media.tumblr.com/595159f392d6497fe1224f3d4c59d961/tumblr_n6dobgl6wT1tc0bnlo1_500.gif',
      'http://66.media.tumblr.com/acfc022d906c10767278adc4b0bd0cb7/tumblr_n5q1wbEP1R1tc0bnlo1_500.gif',
      'http://66.media.tumblr.com/95847806383c203e238b6cc88447ca06/tumblr_n5q3e7v3rl1tc0bnlo1_500.gif',
      'http://imgur.com/BWn4JhM'
    ]
    msg.send msg.random baguette

  robot.respond /aggablagblag$/i, (msg) ->
    schwifty = [
      'https://i.imgur.com/1eFO5v6.png',
      'https://www.youtube.com/watch?v=VlAMsYMNd7g',
      'https://www.youtube.com/watch?v=hup9eowiZHQ'
    ]
    msg.send msg.random schwifty

  robot.respond /pd$/i, (msg) ->
    pagerdootie = [
      'http://i.giphy.com/xTiTnzvzlEj5vD3Tkk.gif',
      'http://i.giphy.com/1306MTkHlXkUZG.gif',
      'http://i.giphy.com/6sI9YC1GJx1G8.gif',
      'http://i.giphy.com/DOdsiolqbxCbm.gif',
      'http://i.imgur.com/6mbgddS.gif'
    ]
    msg.send msg.random pagerdootie

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

  robot.respond /franciskitty$/i, (msg) ->
    franciskitty = [
      'http://i.imgur.com/lk2AF0Z.jpg'
      'http://i.imgur.com/eSl4bjv.jpg'
      'http://i.imgur.com/lLVPGgT.jpg'
      'http://i.imgur.com/u3bnpha.jpg'
      'http://i.imgur.com/AbMV7mZ.jpg'
      'http://i.imgur.com/GQpVxx7.jpg'
      'http://i.imgur.com/AQekPbY.jpg'
      'http://i.imgur.com/8qH7aV2.jpg'
      'http://i.imgur.com/tbqLCZM.jpg'
      'http://i.imgur.com/pP0Wpt4.jpg'
      'http://i.imgur.com/tU4sboO.jpg'
      'http://i.imgur.com/gK8ovRq.jpg'
      'http://i.imgur.com/32hlBIZ.jpg'
      'http://i.imgur.com/8zA5sBF.jpg'
      'http://i.imgur.com/FgyDrnS.jpg'
      'http://i.imgur.com/sFNhpJ7.jpg'
      'http://i.imgur.com/q5eUZzr.jpg'
      'http://i.imgur.com/M6GSXYR.jpg'
      'http://i.imgur.com/VOTJXWf.jpg'
      'http://i.imgur.com/BOtPbYr.jpg'
      'http://i.imgur.com/mPGxexh.jpg'
      'http://i.imgur.com/BWxKv1w.jpg'
      'http://i.imgur.com/iD3Ab3L.jpg'
      'http://i.imgur.com/6XyhrNb.jpg'
      'http://i.imgur.com/bwmpXE9.jpg'
      'http://i.imgur.com/PzFRrnO.jpg'
      'http://i.imgur.com/Wl3FquX.jpg'
      'http://i.imgur.com/YET5N0W.jpg'
      'http://i.imgur.com/LB1ljDc.jpg'
      'http://i.imgur.com/pYmYkPY.jpg'
      'http://i.imgur.com/4N7zupq.jpg'
      'http://i.imgur.com/Nilv8nH.jpg'
      'http://i.imgur.com/5HxTRL2.jpg'
      'http://i.imgur.com/YdjNjSV.jpg'
      'http://i.imgur.com/0XI4zUx.jpg'
      'http://i.imgur.com/PATmKSh.jpg'
      'http://i.imgur.com/rtNkSaK.jpg'
      'http://i.imgur.com/OZI4j9W.jpg'
      'http://i.imgur.com/IFyqmGl.jpg'
      'http://i.imgur.com/XJxoikU.jpg'
      'http://i.imgur.com/J7GIJ01.jpg'
      'http://i.imgur.com/XvmQ6DC.jpg'
      'http://i.imgur.com/1yBuBew.jpg'
      'http://i.imgur.com/eh00hLg.jpg'
      'http://i.imgur.com/TejvjgK.jpg'
      'http://i.imgur.com/oAwN9FI.jpg'
      'http://i.imgur.com/RBoWOw7.jpg'
      'http://i.imgur.com/FSg3ouG.jpg'
      'http://i.imgur.com/bmt83vn.jpg'
    ]
    msg.send msg.random franciskitty

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

  robot.respond /meeks$/i, (msg) ->
    misterseemeeks = [
      'http://i.imgur.com/BuMr8wB.png'
    ]
    msg.send msg.random misterseemeeks

  robot.respond /casey$/i, (msg) ->
    tehcehseh = [
      'http://i.imgur.com/cuxU9VC.gif',
      'http://i.imgur.com/kfyhTcm.gif',
      'https://hipchat.dev.pardot.com/files/1/162/i8CueeiNYtW8YqZ/CaseyPie.gif'
    ]
    msg.send msg.random tehcehseh

  robot.respond /rubbs$/i, (msg) ->
    tehrubbs = [
      'http://i.imgur.com/4R6F3bZ.png',
      'http://i.imgur.com/ECG14iD.gif.png',
      'http://i.imgur.com/MJxHYxq.gif.png',
      'http://i.imgur.com/VbvnB2P.png',
      'https://hipchat.dev.pardot.com/files/1/261/ZZGrAH9oJSAjmq4/reverserubbs.gif',
      'https://hipchat.dev.pardot.com/files/1/261/TglCCcPz8cXOl5s/downwardrubbs.gif',
      'https://hipchat.dev.pardot.com/files/1/261/FvcAWkrQ8y8Fl7O/upwardrubbs.gif',
      'https://hipchat.dev.pardot.com/files/1/282/z9Aj3d510cHFnZG/aZEnsuw.gif'
    ]
    msg.send msg.random tehrubbs


  robot.respond /fondant$/i, (msg) ->
    fondant = [
      'https://media.giphy.com/media/3oxRmsdUQ50pclDYOs/giphy.gif'
    ]
    msg.send msg.random fondant

  robot.respond /panda$/i, (msg) ->
    pandas = [
      'https://media1.giphy.com/media/xT8qB1QeVVwk2NmF0Y/giphy.gif',
      'https://media4.giphy.com/media/12a5jfD4RVTAQw/giphy.gif',
      'https://media3.giphy.com/media/l3vRiLydJmh7X0Yx2/giphy.gif',
      'https://giant.gfycat.com/GaseousGorgeousAracari.gif',
      'http://i.imgur.com/vxKOi.gif',
      'http://i.imgur.com/X6wWnNp.gif',
      'http://i.imgur.com/tPQi76p.jpg',
      'http://i.imgur.com/oeAufrG.gifv',
      'http://i.imgur.com/cNDbs8v.gif',
      'http://i.imgur.com/xy6tM.gif',
      'http://i.imgur.com/F94emFR.jpg'
    ]
    msg.send msg.random pandas

  robot.respond /mikacat$/i, (msg) ->
    mikacat = [
      'http://i.imgur.com/68Bo5g1.jpg',
      'http://i.imgur.com/5neuGdB.jpg',
      'http://i.imgur.com/awlRzL9.jpg',
      'http://i.imgur.com/Hk6qbAV.jpg',
      'http://i.imgur.com/lHGwQTX.jpg',
      'http://i.imgur.com/OUnQRoT.jpg',
      'http://i.imgur.com/bINno4i.jpg',
      'http://i.imgur.com/tomP6ms.jpg',
      'http://i.imgur.com/q4ED3cg.jpg',
      'http://i.imgur.com/Ve1Vme7.jpg',
      'http://i.imgur.com/KFru4xC.jpg',
      'http://i.imgur.com/hagikyl.jpg',
      'http://i.imgur.com/93KPdH0.jpg',
      'http://i.imgur.com/joh02uR.jpg',
      'http://i.imgur.com/NhiezbD.jpg',
      'http://i.imgur.com/9oONlEk.jpg',
      'http://i.imgur.com/pA85cNq.jpg',
      'http://i.imgur.com/Zhfajnq.jpg',
      'http://i.imgur.com/flsoZuD.jpg',
      'http://i.imgur.com/BrJ4Xul.jpg',
      'http://i.imgur.com/KtLAhCQ.jpg',
      'http://i.imgur.com/0X91zRZ.jpg',
      'http://i.imgur.com/VMf7FkO.jpg',
      'http://i.imgur.com/c0zd0Om.jpg',
      'http://i.imgur.com/ZZ1S2h9.jpg',
      'http://i.imgur.com/y41s5aS.jpg',
      'http://i.imgur.com/nOGsE0o.jpg',
      'http://i.imgur.com/11zzQJm.jpg',
      'http://i.imgur.com/30SpOgT.jpg',
      'http://i.imgur.com/jzC6NJ2.jpg',
      'http://i.imgur.com/zX1mcBZ.jpg',
      'http://i.imgur.com/3FhrmIq.jpg',
      'http://i.imgur.com/jqDqcup.jpg',
      'http://i.imgur.com/Fd6jnkL.jpg',
      'http://i.imgur.com/uCyoFL0.jpg',
      'http://i.imgur.com/O3dirZa.jpg',
      'http://i.imgur.com/R1YCz5n.jpg',
      'http://i.imgur.com/OeNu0IY.jpg',
      'http://i.imgur.com/xBz26I2.jpg',
      'http://i.imgur.com/QUTaTZ1.jpg',
      'http://i.imgur.com/n6UVBgj.jpg',
      'http://i.imgur.com/gexttJg.jpg',
      'http://i.imgur.com/a6TtW1m.jpg',
      'http://i.imgur.com/2RUnSBr.jpg',
      'http://i.imgur.com/5frQNxC.jpg',
      'http://i.imgur.com/ACEv0wO.jpg',
      'http://i.imgur.com/wJJ6ftj.jpg',
      'http://i.imgur.com/LmPlOms.jpg',
      'http://i.imgur.com/sxTp34l.jpg',
      'http://i.imgur.com/ARxMovy.jpg',
      'http://i.imgur.com/ySlWcLA.jpg'
    ]
    msg.send msg.random mikacat

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

  robot.respond /et$/i, (msg) ->
    msg.send "https://hipchat.dev.pardot.com/files/1/72/ON7zc24WS4tfT1M/IMG_0925.JPG"

  robot.respond /waffles$/i, (msg) ->
    waffleses = [
      "http://i.imgur.com/8TkPJcP.gif",
      "https://hipchat.dev.pardot.com/files/1/282/7QJbcMToMrhk7ZR/2016-03-30%2016_31_37.gif"
    ]
    msg.send msg.random waffleses

  robot.respond /excuse(\sme)?(?:\s+(.*))?$/i, (msg) ->
    url = 'http://pe-api.herokuapp.com/'
    if msg.match[1]
      msg.send "Oh, did you fart? (disapproval)"
      return
    target = msg.match[2]
    msg.http(url)
      .get() (error, res, body) ->
        if error
          msg.send "Programming Excuses server failed to respond: #{error}"
        else
          payload = JSON.parse(body)
          response = if payload.message then payload.message else "It probably won't happen again (shrug)"
          if target
            rand = Math.floor(Math.random() * 3)
            if rand is 0
              msg.send "I recall #{target} saying, \"#{response}\""
            else if rand is 1
              msg.send "To quote #{target} precisely:"
              msg.send "/quote #{response}"
            else if rand is 2
              msg.send "\"#{response}\" - #{target}"
          else
            msg.send response

  robot.respond /blame\s*(.*)?$/i, (msg) ->
    target = msg.match[1] || "@ian"

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

  robot.respond /css$/i, (msg) ->
    css = [
      'http://i.imgur.com/lLhBzQ3.jpg'
    ]
    msg.send msg.random css


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
      'https://i.imgur.com/KZf5kWZ.png',
      'https://hipchat.dev.pardot.com/files/1/282/rqc8fbRx4NvHwop/2016-02-12%2014_42_30.gif'
    ]

    msg.send msg.random panics

  robot.respond /engage$/i, (msg) ->
    engages = [
      'http://i.imgur.com/kSUHUU7.gif.png',
      'http://i.imgur.com/MX458aQ.jpg',
      'http://i.imgur.com/s4kO6Zj.gif.png',
      'http://i.imgur.com/GfzcTu0.gif.png',
      'http://i.imgur.com/utFIfjv.gif.png',
      'http://i.imgur.com/pjEU3Fo.gif.png',
      'http://i.imgur.com/Y6PRvR3.gif.png',
      'http://i.imgur.com/KQujX2P.gif.png',
      'http://i.imgur.com/JuA0Ts4.gif.png',
      'http://i.imgur.com/otOwD1Q.gif.png',
      'http://i.imgur.com/O0t44wR.gif.png',
      'http://i.imgur.com/bjc4vlo.gif.png',
      'http://i.imgur.com/yEyw4FU.gif.png',
      'http://i.imgur.com/HgjO87I.gif.png',
      'http://i.imgur.com/QJvY45C.gif.png',
      'http://i.imgur.com/gGDcx0W.gif.png',
      'http://i.imgur.com/R0ZVqSo.gif.png',
      'http://i.imgur.com/4LWaG0a.gif.png',
      'http://i.imgur.com/e2WJpvI.gif.png'
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
      "https://hipchat.dev.pardot.com/files/1/65/sWAGNmuFsb4TOjt/Kyle%20Gets%20Weird.gif",
      "http://i.imgur.com/DdEEkOw.gifv",
      "https://hipchat.dev.pardot.com/files/1/235/DfSuBe6injLobrN/IMG_20160519_183230.jpg",
    ]

  robot.respond /superkyle$/i, (msg) ->
    msg.send msg.random [
      "https://hipchat.dev.pardot.com/files/1/139/p2nyPWIpuRJsELg/Screen%20Shot%202015-11-13%20at%203.34.37%20PM.png",
      "https://hipchat.dev.pardot.com/files/1/197/5QzZH6beJLMlDoH/superkyle.gif"
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
      "https://hipchat.dev.pardot.com/files/1/282/rqc8fbRx4NvHwop/2016-02-12%2014_42_30.gif",
      "https://hipchat.dev.pardot.com/files/1/42/ttSs2Ol0zENJGq0/TBone.jpeg",
      "https://i.imgur.com/CxladXR.gif.png"
    ]

    msg.send msg.random tbones

  robot.respond /dartz/i, (msg) ->
    dartzs = [
      "https://hipchat.dev.pardot.com/files/1/287/EbSCbGnuhIxlbJq/IMG_2698%20%281%29.JPG",
      "https://hipchat.dev.pardot.com/files/1/69/TFrXosSJjg5I4il/ezgif.com-gif-maker.gif"
    ]

    msg.send msg.random dartzs

  robot.respond /megaman$/i, (msg) ->
    msg.send "https://hipchat.dev.pardot.com/files/1/287/tvREs1l3wGBhQIR/Screen%20Shot%202016-02-22%20at%2010.51.36%20AM.png"

  robot.respond /squirrelmaster$/i, (msg) ->
    msg.send "https://hipchat.dev.pardot.com/files/1/287/NsridkQpvzIyzsu/squirrelmaster.png"

  robot.respond /bestfriends$/i, (msg) ->
    bestfriendss = [
      "https://hipchat.dev.pardot.com/files/1/22/MO21rCEkbDsiomt/phoobs.gif"
    ]

    msg.send msg.random bestfriendss


  robot.respond /it\'?s\s?happening$/i, (msg) ->
    happenings = [
      "http://i.kinja-img.com/gawker-media/image/upload/19c35oidyf35igif.gif",
      "http://i.imgur.com/T67NQsm.gif"
    ]

    msg.send msg.random happenings


  robot.respond /situation$/i, (msg) ->
    msg.send "https://hipchat.dev.pardot.com/files/1/39/VW6iFJhRbY0AYVy/belinda_situation.jpg"


  robot.respond /nope$/i, (msg) ->
    msg.send "http://media.giphy.com/media/b4pPnoO1QDd1C/giphy.gif"

  robot.respond /catbongos$/i, (msg) ->
    why_cats_playing_bongos_of_course=[
      'http://media2.giphy.com/media/c57rkrOxZGfTi/giphy.gif',
      'https://media3.giphy.com/media/dAmyloqasB48E/200.gif',
      'http://i.imgur.com/Xa31J4O.gif.png',
      'http://media2.giphy.com/media/3BVbN30qgZZvO/giphy.gif',
      'http://media3.giphy.com/media/11tyQ1rFQuNGrS/giphy.gif'
    ]
    msg.send msg.random why_cats_playing_bongos_of_course

  robot.respond /(tldr|tl;dr)$/i, (msg) ->
    TLDRS=[
      'http://media4.giphy.com/media/EeIzKI0uDz916/giphy.gif',
      'http://media2.giphy.com/media/YOvJuai8jPGpO/giphy.gif',
      'http://media4.giphy.com/media/ToMjGpqWojvqz7ts2li/giphy.gif',
      'http://media3.giphy.com/media/lcmYVxHTvkOLC/giphy.gif'
    ]
    msg.send msg.random TLDRS

  robot.respond /sysadmin$/i, (msg) ->
    sysadmins=[
      'http://i.imgur.com/V5FpuGB.jpg',
      'http://i.imgur.com/7zkAZld.jpg',
      'http://i.imgur.com/1QxEnDK.jpg',
      'http://i.imgur.com/ZahKqeH.jpg',
      'http://i.imgur.com/9xhmLjw.jpg',
      'http://i.imgur.com/l2mEYwX.jpg',
      'http://i.imgur.com/8Ezom3u.jpg',
      'http://i.imgur.com/dLrz9D4.jpg',
      'http://i.imgur.com/nOV5HZz.jpg',
      'http://i.imgur.com/xEkdnNp.jpg',
      'http://i.imgur.com/qjYCPWj.jpg',
    ]
    msg.send msg.random sysadmins

  robot.respond /starpugs$/i, (msg) ->
    starpugs=[
      'https://hipchat.dev.pardot.com/files/1/380/RQgJ29Lx4WyE2p6/banthapug.jpg',
      'https://hipchat.dev.pardot.com/files/1/380/LfIBjGgienBuKuq/darth_pug.jpg',
      'https://hipchat.dev.pardot.com/files/1/380/2DbOy3Ad9qoyiMx/pug_skywalker.jpg',
      'https://hipchat.dev.pardot.com/files/1/380/IxvVvYHId5PK4YN/leia_darth_pug.jpg',
      'https://hipchat.dev.pardot.com/files/1/380/gtMxmgqjy1cOzyn/bring-me-solo.jpg',
      'https://hipchat.dev.pardot.com/files/1/380/dEU27jDJyGpvMfD/ewok_pug.jpg',
      'https://hipchat.dev.pardot.com/files/1/380/B5ZH7Tavt2AYGcO/4starwarspugs.jpg',
      'https://hipchat.dev.pardot.com/files/1/380/Z4yi4ePMA6YUOZi/xwing_pug.jpg',
      'https://hipchat.dev.pardot.com/files/1/380/XYMhlSyflHuj43u/bb-pug.png',
      'https://hipchat.dev.pardot.com/files/1/380/eCMQZMHfcEkbt7U/yoda_pug.jpg',
    ]
    msg.send msg.random starpugs

  robot.respond /hybrid$/i, (msg) ->
    hybrid=[
      'http://www.freakingnews.com/pictures/128500/Hybrid-pets--128901.jpg',
      'https://s-media-cache-ak0.pinimg.com/736x/5f/5b/4b/5f5b4bba9e656b1fbf12c73d203fde58.jpg',
      'https://media.mnn.com/assets/images/2014/06/hybrid%20banana%20large.jpg',
      'https://s-media-cache-ak0.pinimg.com/236x/21/04/72/210472376ed1a284f5e7a8638b1b88aa.jpg'
    ]
    msg.send msg.random hybrid

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

  robot.respond /(?:(please|pls),?\s*)?(don(?:')?t|do not)\s*(touch|pet|scratch|mess with)\s*doge(?:!*)?(.*)?$/i, (msg) ->
    msg.send "http://media3.giphy.com/media/jUSrFvui8Pfpe/giphy.gif"

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

  robot.respond /(?:gif|giphy)(?: me)? (.*)/i, (msg) ->
    gifMe msg, msg.match[1], (url) ->
      msg.send "#{url}"

  robot.respond /lightning$/i, (msg) ->
    msg.send "https://hipchat.dev.pardot.com/files/1/252/cWFbm8VYCnHmmaN/Rage_Lightning.jpg"

  gifMe = (msg, query, cb) ->
    googleCseId = process.env.HUBOT_GOOGLE_CSE_ID
    googleApiKey = process.env.HUBOT_GOOGLE_API_KEY

    sites = [
      "site:i.imgur.com",
      "site:reactiongifs.com",
      "site:giphy.com"
    ]

    if sites.length > 0
      query += " ("
      query += sites.join " OR "
      query += ")"

    console.log query
    q =
      q: query,
      searchType:'image',
      fileType:'gif'
      num: 10,
      safe:'high',
      cx: googleCseId,
      key: googleApiKey
    url = 'https://www.googleapis.com/customsearch/v1'
    msg.http(url)
      .query(q)
      .get() (err, res, body) ->
        if err
          msg.send "Encountered an error :( #{err}"
          return
        response = JSON.parse(body)
        if response?.error
          msg.send "Encountered an error :( #{response.error.message}"
        else if response?.items
          image = msg.random response.items
          cb ensureImageExtension image.link
        else
          msg.send "I couldn't find any results for that search (sadpanda)"

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
    googleCseId = process.env.HUBOT_GOOGLE_CSE_ID
    if googleCseId
  # Using Google Custom Search API
      googleApiKey = process.env.HUBOT_GOOGLE_API_KEY
      if !googleApiKey
        msg.robot.logger.error "Missing environment variable HUBOT_GOOGLE_API_KEY"
        msg.send "Missing server environment variable HUBOT_GOOGLE_API_KEY."
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
    chunks = url.split('.')
    ext = chunks.pop()
    if /(png|jpe?g|gif$)/i.test(ext)
      gifUrl = url
    else if /(gifv$)/i.test(ext)
      chunks.push('gif')
      gifUrl = chunks.join('.')
    else
      gifUrl = "#{url}#.png"
    return ensureGiphyExtension(gifUrl)

  ensureGiphyExtension = (url) ->
    if not /(.*)giphy.com(.*)/i.test("#{url}")
      return url
    chunks = url.split('/')
    end = chunks.pop()
    console.log url
    if not /^(giphy.gif)$/i.test(end)
      chunks.push "giphy.gif"
      return chunks.join('/')
    else
      return url
