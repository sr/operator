thebattle = [
  "http://static2.nerduo.com/thebattle_zoom.png"
  "http://img.skitch.com/20090805-g4a2qhttwij8n2jr9t552efn3k.png"
]

soons = [
  "http://i2.kym-cdn.com/photos/images/newsfeed/000/117/008/soon_honey_beer_bottle.jpg"
  "http://i2.kym-cdn.com/photos/images/newsfeed/000/117/009/soon.jpg"
  "http://i3.kym-cdn.com/photos/images/newsfeed/000/117/013/cjZXR.jpg"
  "http://i3.kym-cdn.com/photos/images/newsfeed/000/117/021/enhanced-buzz-28895-1301694293-0.jpg"
  "http://i3.kym-cdn.com/photos/images/newsfeed/000/117/022/enhanced-buzz-28904-1301694302-1.jpg"
]

wins = [
  "http://badabingbadabambadaboom.files.wordpress.com/2011/04/charlie-sheen-winning-tshirt.jpg?w=604"
  "http://onstartups.com/Portals/150/images/charlie-sheen-winning-resized-600.jpg"
  "http://i1.sndcdn.com/artworks-000033774973-xsrty5-original.png?2479809"
  "http://meldilla.mywapblog.com/files/charlie-sheen-winning.jpg"
  "http://2.bp.blogspot.com/-8IEPahii4Qo/TvBxt3soC1I/AAAAAAAAA5g/PUAy9ODW4mY/s1600/Charlie%2BSheen%2Bwinning.png"
  "http://925.nl/images/2012-06/winning-charlie-sheen-sweatshirts_design.png"
  "http://www.pokernews.com/w/articles/4d75/e406c8b92.jpg"
]


module.exports = (robot) ->
  if process.env.BOT_TYPE != 'internbot'
    return

  robot.hear /^botsnack/i, (msg) ->
    msg.send ":D"

  robot.hear /do.* it live/i, (msg) ->
    msg.send "http://rationalmale.files.wordpress.com/2011/09/doitlive.jpeg"

  robot.hear /more you know/i, (msg) ->
    msg.send "http://i957.photobucket.com/albums/ae55/mttrek360/the_more_you_know2.jpg"

  robot.hear /^!source/i, (msg) ->
    msg.send "https://github.com/pardot/parbot"

  robot.hear /knowing is half the battle/i, (msg) ->
    msg.send msg.random thebattle

  robot.hear /SOON/, (msg) ->
    msg.send msg.random soons

  robot.hear /winning/i, (msg) ->
    msg.send msg.random wins
