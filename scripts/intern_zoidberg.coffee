_ = require 'underscore'
Request  =  require  'request'
Cheerio  =  require  'cheerio'
Scraper = require 'scraper'

quotes = []
zoidbergQuotes = []
benderQuotes = []
professorQuotes = []
fryQuotes = []

options =
  'uri': 'http://en.wikiquote.org/wiki/Futurama'
  'headers':
    'User-Agent': 'User-Agent: Futuramabot for Hubot (+https://github.com/github/hubot-scripts)'

## This could be improved, the whole jsdom stuff seems to cause hubot to hang for a while.
console.log("Quotes? Why not zoidberg?")
Scraper options, (err, $) ->
  return console.log err if err
  allQuotes = _($('dl').toArray()).map (dl) ->
    $(dl).text().trim()

  _(allQuotes).each (text) ->
    zoidbergQuotes.push(text) if /zoidberg/i.test text
    professorQuotes.push(text) if /farnsworth/i.test text
    benderQuotes.push(text) if /bender/i.test text
    fryQuotes.push(text) if /fry/i.test text
    quotes.push(text)

  console.log "futurama quotes ready, #{allQuotes.length} quotes found"

module.exports = (robot) ->
  if process.env.BOT_TYPE != 'internbot'
    return

  robot.hear /!zoidberg/, (msg) ->
    msg.send msg.random zoidbergQuotes
  robot.hear /!professor/, (msg) ->
    msg.send msg.random professorQuotes
  robot.hear /!bender/, (msg) ->
    msg.send msg.random benderQuotes
  robot.hear /!fry/, (msg) ->
    msg.send msg.random fryQuotes

  robot.hear /!futurama (.*)$/, (msg) ->
    match = new RegExp msg.match[1], 'i'
    filteredQuotes = _(quotes).filter (quote) -> match.test quote
    msg.send msg.random filteredQuotes
