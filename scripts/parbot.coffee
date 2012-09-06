# Description:
#   Basic Parbot utils
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   None
#

Array::shuffle = -> @sort -> 0.5 - Math.random()

module.exports = (robot) ->
    robot.hear /^!blame\s+(.*)/i, (msg) ->
        target = msg.match[1]

        blames = [
            "#{target} is responsible!",
            "#{target} makes questionable decisions",
            "#{target} breaks most things around here",
            "#{target} caused the current problem",
            "#{target} did it!"
        ]
        
        blames.shuffle()
        msg.send blames[0]

    robot.hear /^!praise\s+(.*)/i, (msg) ->
        target = msg.match[1]

        compliments = [
            "#{target} is a pillar of virtue",
            "#{target} has swagger for days",
            "Let the word go forth from this time and place, that #{target} will be known as a winner.",
            "#{target}, you are my hero",
            "All good work done shall bear #{target}'s name. So let it be written, so it shall be done.",
            "Today, #{target} brought forth in this room a feat of great success, conceived in magnificence, and dedicated to awesomeness.",
            "Today, #{target} suddenly and deliberately kicked some ass",
            "#{target} makes it WERK"
        ]
        
        compliments.shuffle()
        msg.send compliments[0]

    robot.hear /^!opme\s+(.*)/i, (msg) ->
        target = msg.match[1]

        console.log msg.robot.adapter.bot

        robot.fooey '112'
        robot.command "mode", "+o #{target}"




