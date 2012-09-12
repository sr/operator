
# Get all nicknames from the robot
module.exports.getAllNicks = (robot) ->
    (v.name for k,v of robot.users())

# Find an engineer based on nickname
module.exports.findEngineer = (nickname) ->
    engineers = [
        { name: "berg", list: ["berg"] },
        { name: "evinti", list : ["evinti"] },
        { name: "ian", list : ["ian"] },
        { name: "jarrett", list : ["jarrett", "jart"] },
        { name: "meredith", list : ["meredith"] },
        { name: "reid", list : ["reid"] },
        { name: "stokes", list : ["stokes"] },
        { name: "wino", list : ["wino"] },
        { name: "steviep", list : ["steviep", "stephen", "stephen_laptop"] }
    ]

    for engineer in engineers
        for nick in engineer.list
             if nickname.match(/^nick/) is not null
                return engineer.name

    false