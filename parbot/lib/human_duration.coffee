class HumanDuration
  @parseToMilliseconds: (str) ->
    if matches = str.match(/^(\d+)(d|day|day)$/)
      parseInt(matches[1]) * 1000*60*60*24
    else if matches = str.match(/^(\d+)(h|hr|hrs|hour|hours)$/)
      parseInt(matches[1]) * 1000*60*60
    else if matches = str.match(/^(\d+)(m|min|mins|minute|minutes)$/)
      parseInt(matches[1]) * 1000*60
    else if matches = str.match(/^(\d+)(s|sec|secs|second|seconds)$/)
      parseInt(matches[1]) * 1000
    else
      null

module.exports = HumanDuration
