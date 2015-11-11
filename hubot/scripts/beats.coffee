# Description
#   Tell the time like it's '99
#
# Commands
#   beats
#

currentTimeInBeats = ->
  # ruby impl
  # seconds, minutes, hours = getutc.to_a
  # (((hours + 1) * 3600 + (minutes * 60) + seconds) / 86.4).to_i
  beat_in_seconds = 86.4

  now = new Date
  hours = now.getUTCHours()
  hours = if hours == 23 then 0 else hours + 1
  minutes = now.getUTCMinutes()
  seconds = now.getUTCSeconds()

  biel_mean_time = (hours * 60 + minutes) * 60 + seconds

  beats = Math.floor(biel_mean_time / beat_in_seconds)

  '@'.concat('000'.concat(beats).slice(beats.toString().length))

module.exports = (robot) ->
  robot.respond /beats/i, (msg) ->
    msg.send currentTimeInBeats()

# this lets us test this script by invoking it on the command line
if !module.parent
  console.log currentTimeInBeats()
