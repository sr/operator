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

util = require "../lib/util"

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

        

        console.log getAllNicks()

        #console.log msg.robot.adapter.bot

        #robot.fooey '112'
        #robot.command "mode", "+o #{target}"

     # Chikins runnin wild
    robot.hear /^!chikin$/i, (msg) ->
        chikins = [
            'bucka bucka bucka BUCKA BUACKA baaaaaaAAAA'
            'cuh-KA cuh-KA cuh-KA KA',
            'AH-coodle-doodle-doo AH-coodle-doodle-doo',
            'chee CHAH chee CHAH chee CHAH',
            'cookoo KATCHA cookoo KATCHA'
        ].shuffle()
        
        msg.send chikins[0]
        
    # A cow got loose
    robot.hear /^!moo$/i, (msg) ->
        msg.send 'Mooooooo000000000ooooooo000000000ooooooo!!'

    # Hate on someone
    robot.hear /^!hate$/i, (msg) ->
        msg.send 'hate hate hate'
        
    # Quit hatin
    robot.hear /^!hater$/i, (msg) ->
        msg.send 'haters gonna hate'
        
    # Poop on someone
    robot.hear /^!poop$/i, (msg) ->
        poops = [
            'plop plop blaaaaaart',
            'plooop',
            'pffffft'
            'ploppity plop ploooooooop',
            'toot'
        ].shuffle()

        allNicks = util.getAllNicks robot
        allNicks.shuffle()

        msg.send "I choose #{allNicks[0]}"
        robot.send allNicks[0], poops[0]
    
    # Get some random nickname
    robot.hear /^!random$/i, (msg) ->
        allNicks = util.getAllNicks robot
        allNicks.shuffle()

        msg.send "#{allNicks[0]}, I choo choo choose you!"

