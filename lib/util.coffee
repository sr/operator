
module.exports.getAllNicks = (robot) ->
    (v.name for k,v of robot.users())