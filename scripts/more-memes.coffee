# Description:
#   Moar memes from http://memecaptain.com/
#   This extends the hubot-meme external script. Add more memes!
#   API Docs at:
#   github.com/mmb/meme_captain_web/blob/master/doc/api/create_meme_image.md
#
# Dependencies:
#   hubot-meme
#
# Commands:
#   ! YOU GET <text> - Meme: Oprah gives you the things!
#   ! DR. EVIL QUOTE <text> - Meme: Dr. Evil finger-quoted text
#   ! HEAVE <text> - Meme: Jim Carrey dry heaving + text
#   ! WORKING ON <text> - Meme: Cat typing on MacBook Pro
#   ! DUDE YOU'RE GETTING A <text> - Meme: Dell guy
#   ! THIS IS <text> - Meme: 300 Sparta meme
#   ! DUMPSTER FIRE <text> - Meme: Name your own dumpster fire!
#
# Author:
#   brianhays

memeGenerator = require "hubot-meme/src/lib/memecaptain.coffee"

module.exports = (robot) ->
  robot.respond /YOU GET (.*)/i, id: 'meme.oprah-you-get', (msg) ->
    memeGenerator msg, 'Ux_jDw', 'You get ' + msg.match[1] + '!' +
    ' and you get ' + msg.match[1] + '!', 'Everybody gets ' + msg.match[1] + '!'

  robot.respond /DR.? EVIL QUOTE (.*)/i, id: 'meme.dr-evil-quote', (msg) ->
    memeGenerator msg, 'SdxrkQ', '', '" ' + msg.match[1] + ' "'

  robot.respond /HEAVE (.*)/i, id: 'meme.dry-heave', (msg) ->
    memeGenerator msg, '7MX6Hw', '', msg.match[1]

  robot.respond /WORKING ON (.*)/i, id: 'meme.working-on', (msg) ->
    memeGenerator msg, 'gCpvKg', 'Working on ', msg.match[1]

  robot.respond /DUDE YOU'?RE? GETTING A (.*)/i, id: 'meme.dell-guy', (msg) ->
    memeGenerator msg, 'iXkgvA', 'Dude, you\'re getting a', msg.match[1]

  robot.respond /THIS IS (.+)$/i, id: 'meme.spardotify', (msg) ->
    # characters we can duplicate to make it Spartaaaaaaa
    spartafyChars = ['a', 'i', 'o', 'u', 'e']
    sparta = ''

    # we'll only duplicate one vowel
    extended = false

    mytext = msg.match[1]

    # handle words over two chars in length that end in 'e'
    # we don't want cakeeeeee we want caaaaaake!
    if mytext.charAt(mytext.length-1) == 'e' and mytext.length > 2
      spartafyChars.pop()

    # reverse the text for handling
    for c in mytext.split("").reverse().join ""
      if c in spartafyChars and not extended
        sparta += c for _ in [1..6]
        extended = true
      else
        sparta += c

    # re-reverse :) the new spardotified string
    spardot = sparta.split("").reverse().join ""

    memeGenerator msg, 'O9St3w', 'This is', spardot + "!!!"

  robot.respond /DUMPSTER FIRE (.*)/i, id: 'meme.dumpster-fire', (msg) ->
    memeGenerator msg, 'hEeVrg', '', msg.match[1]
