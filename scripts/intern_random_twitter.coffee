module.exports = (robot) ->
  if process.env.BOT_TYPE != 'internbot'
    return

  Twit  =  require 'twit'
  _     =  require 'underscore'

  T = new Twit
    consumer_key:         process.env.TWITTER_CONSUMER_KEY
    consumer_secret:      process.env.TWITTER_CONSUMER_SECRET
    access_token:         process.env.TWITTER_ACCESS_TOKEN
    access_token_secret:  process.env.TWITTER_ACCESS_TOKEN_SECRET

  Commands = [
    { command: /^!antijoke/, user: 'antijokecat' }
    { command: /^!uberfact/, user: 'uberfacts' }
    { command: /^!borat/,    user: 'devops_borat' }
    { command: /^!grimlock/, user: 'fakegrimlock' }
    { command: /^!nph/,      user: 'ActuallyNPH' }
    { command: /^!drunkhulk/, user: 'DrunkHulk' }
    { command: /^!deathstar/, user: 'DeathStarPR' }
    { command: /^!yoda/, user: 'yoda' }
    { command: /^!couragewolf/, user: 'courage_wolf' }
    { command: /^!compscifact/, user: 'compscifact' }
  ]

  for command in Commands
    do (command) ->
      robot.hear command.command, (msg) ->
        T.get 'statuses/user_timeline', { screen_name: command.user, exclude_replies: 'true' }, (err, reply) ->
          return console.log err if err
          tweet = _(reply).chain().shuffle().first().value()?.text
          msg.send tweet


  robot.hear /^!twitter (\w+)/, (msg) ->
    T.get 'statuses/user_timeline', { screen_name: msg.match[1], exclude_replies: 'true' }, (err, reply) ->
      return console.log err if err
      tweet = _(reply).chain().shuffle().first().value()?.text
      msg.send tweet

  robot.hear /^!twitter #(\w+)/, (msg) ->
    T.get 'search/tweets', { q: "##{msg.match[1]}" }, (err, reply) ->
      return console.log err if err
      tweet = _(reply.statuses).chain().shuffle().first().value()?.text
      msg.send tweet

  robot.hear /^!trends/, (msg) ->
    T.get 'trends/place', { id: '2450022' }, (err, reply) ->
      return console.log err if err
      trends = _(reply[0]?.trends).chain().pluck('name').filter((name) -> /^#/.test name).value()
      msg.send trends.join ', '
