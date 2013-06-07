ackbars = [
  "http://dayofthejedi.com/wp-content/uploads/2011/03/171.jpg",
  "http://dayofthejedi.com/wp-content/uploads/2011/03/152.jpg",
  "http://farm4.static.flickr.com/3572/3637082894_e23313f6fb_o.jpg",
  "http://www.youtube.com/watch?v=dddAi8FF3F4",
  "http://6.asset.soup.io/asset/0610/8774_242b_500.jpeg",
  "http://files.g4tv.com/ImageDb3/279875_S/steampunk-ackbar.jpg",
  "http://farm6.staticflickr.com/5126/5725607070_b80e61b4b3_z.jpg",
  "http://www.x929.ca/shows/newsboy/wp-content/uploads/admiral-ackbar-mouse-trap.jpg",
  "http://farm6.static.flickr.com/5291/5542027315_ba79daabfb.jpg",
  "http://farm5.staticflickr.com/4074/4751546688_5c76b0e308_z.jpg",
  "http://farm6.staticflickr.com/5250/5216539895_09f963f448_z.jpg"
]

tarps = [
  "http://halbertri.tripod.com/images/tarpB.gif"
  "http://t0.gstatic.com/images?q=tbn:ANd9GcSos2xLheyisfd4a5NT_xNOmFBI9XmReBvRRJm-xSQtKUFs9YAO0r9MP4rg"
  "http://2.bp.blogspot.com/-m1aA4ROvlsQ/T12C8L6mgJI/AAAAAAAAHlI/h0WVlrS0uYE/s1600/its_a_tarp.gif"
  "http://gossamergear.com/media/catalog/product/cache/1/image/9df78eab33525d08d6e5fb8d27136e95/s/p/spinntwinn1-300_1.jpg"
  "http://www.bensbackwoods.com/catalog/etowah%20tarp%20pcs%202.JPG"
]

module.exports = (robot) ->
  if process.env.BOT_TYPE != 'internbot'
    return

  robot.hear /it'?s a trap\b/i, (msg) ->
    msg.send msg.random ackbars

  robot.hear /it'?s a tarp\b/i, (msg) ->
    msg.send msg.random tarps
