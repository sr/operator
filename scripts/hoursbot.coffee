# Description:
#   HoursBot commands
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

cronJob = require('cron').CronJob;
utils   = require('./lib/utils');
var mongo   = require('mongodb'),
    Server  = mongo.Server,
    Db      = mongo.Db;
    
var server = new Server('localhost', 27017, {auto_reconnect: true});
var db     = new Db('engineering', server);


module.exports = (robot) ->
    # Record hours
    robot.hear /^!hours\s+(\d+)$/i, (msg) ->
        if !hoursBotEnabled then return
        hours = joinInfo msg.match[1]

        if hours > 24
            msg.send "You cant work more than 24 hours in a day!"
        else



updateHours = (engineer, nickHours, date) ->
    hoursDate = getYesterday()
    
    if hoursDate == null
        return 'fail';
    
    if (date != false && typeof date != 'undefined') {
        hoursDate = date;
    }
    
    if (nickHours > 24) {
        nickHours = 8;
    }
    
    db.open(function(err, db) {
        if(!err) {
            db.collection('hours', function(err, collection) {
                // Get everyone that sent in hours for this date
                collection.find({name: engineer, date : hoursDate}).toArray(function(err, items) {
                    if (items.length == 0) {
                        collection.save({name: engineer, date : hoursDate, hours : nickHours});
                    } else {
                        var existing = items[0];
                        existing.hours = nickHours;

                        // Resave
                        collection.save(existing);
                    }
                    
                    // Shut it down
                    db.close();
    
    nickHours



# Is supportbot enabled for this bot?
hoursBotEnabled = () ->
    unless process.env.HOURSBOT_ENABLED == 'true'
        false
    true


###

client.addListener('message', function (from, to, message) {
    var hoursRegex = /^!panic$/;
    var match      = hoursRegex.exec(message);
    
    if (match != null && match.length > 1) {
        client.say(ircRoom, 'oh god oh god oh god oh god!')
    }
});

// Listener for hours command
client.addListener('message', function (from, to, message) {
    var hoursRegex = /^!hours\s+(\d+)$/;
    var match      = hoursRegex.exec(message);
    
    if (match != null && match.length > 1) {
        var engineer = nickEngineerMatch(from);
        
        if (engineer != false) {            
            var realHours = updateHours(engineer, match[1], false);
            client.say(from, 'Thanks! I recorded ' + realHours);
        }
    }
});

// Listener for hours with date command
client.addListener('message', function (from, to, message) {
    var dateRegex = /^!hours\s+(\d+)\s(.+)/;
    var dateMatch = dateRegex.exec(message);
    
    if (dateMatch != null && dateMatch.length > 1) {
        var engineer = nickEngineerMatch(from);
        
        var parseDate = Date.parse(dateMatch[2]);
        
        // Cant parse the date!
        if (parseDate == null) {
            client.say(from, 'I cant parse that date, try again dude.');
        } else {
            // Reformat
            parseDate = parseDate.toString(dateFormat);
            
            if (engineer != false) {
                var realHours = updateHours(engineer, dateMatch[1], parseDate);
                client.say(from, 'Thanks! I recorded ' + realHours + ' for ' + parseDate);
            }
        }
    }
});

// Listener for ignore command
client.addListener('message', function (from, to, message) {
    var ignoreRegex = /^!ignore\s+(\w+)$/;
    var ignoreMatch = ignoreRegex.exec(message);
    
    if (ignoreMatch != null && ignoreMatch.length > 1) {
        var engineer = nickEngineerMatch(ignoreMatch[1]);
        
        if (engineer != false) {
            updateHours(engineer, 'ignore', false);
            client.say(ircRoom, 'Ignoring ' + engineer)
        }
    }
});

// Listener for lastweek avg command
client.addListener('message', function (from, to, message) {
    var avgRegex = /^!lastweekavg$/;
    var avgMatch = avgRegex.exec(message);
    
    if (avgMatch != null) {
        
        getWeekAvg(getLastWeek(), function(list, avg) {
            var say = "";
            
            engineers.forEach(function(engineer){
               say += engineer.name + ": " + list[engineer.name].weekAvg + ", "; 
            });
            
            client.say(from, say);
            client.say(from, "Total weekly average: " + avg);
        });
    }
});

// Listener for this week avg command
client.addListener('message', function (from, to, message) {
    var avgRegex = /^!thisweektotals$/;
    var avgMatch = avgRegex.exec(message);
    
    if (avgMatch != null) {
        
        getWeekTotals(getThisWeek(), function(list, avg) {
            if (list.length == 0) {
                client.say(from, "Nothing so far.");
            } else {
                var say = "";

                engineers.forEach(function(engineer){
                    say += engineer.name + ": " + list[engineer.name].hours + ", "; 
                });

                client.say(from, say);
            }
        });
    }
});

// Maintain nick list in channel
client.addListener('names', function (channel, nicks) {
    if (channel == ircRoom) {
        engineers.forEach(function(engineer) {
            var engineerFound = false;
            
            engineer.list.forEach(function(listNick) {                
                for (var nick in nicks) {
                    var regex = new RegExp('^' + listNick, 'i');

                    // Make sure its a valid nick
                    if (regex.test(nick) == true) {
                        engineerFound = true;
                    }
                };
                
                engineer.inRoom = engineerFound;
            });
        });
    }
});

// See if the from user matches an engineer, return engineer base name
function nickEngineerMatch(nick) {
    var returnVal = false;
    
    engineers.forEach(function(engineer) {        
        engineer.list.forEach(function(listNick){
            var regex = new RegExp('^' + listNick, 'i');
            
            // Make sure its a valid nick
            if (regex.test(nick) == true) {
                returnVal = engineer.name;
            }     
        });
    });
    
    return returnVal;
}

// Update an engineers hours
function updateHours(engineer, nickHours, date) {
    var hoursDate = getYesterday();
    
    if (hoursDate == null) {
        return 'fail';
    }
    
    if (date != false && typeof date != 'undefined') {
        hoursDate = date;
    }
    
    if (nickHours > 24) {
        nickHours = 8;
    }
    
    db.open(function(err, db) {
        if(!err) {
            db.collection('hours', function(err, collection) {
                // Get everyone that sent in hours for this date
                collection.find({name: engineer, date : hoursDate}).toArray(function(err, items) {
                    if (items.length == 0) {
                        collection.save({name: engineer, date : hoursDate, hours : nickHours});
                    } else {
                        var existing = items[0];
                        existing.hours = nickHours;

                        // Resave
                        collection.save(existing);
                    }
                    
                    // Shut it down
                    db.close();
                });
            });
        }
    });
    
    return nickHours;
}

// Get whatever 'yesterday' was
function getYesterday() {
    // Setup yesterdays date
    var hoursDate = new Date();

    // If today is monday, record for friday
    if (hoursDate.getDay() == 1) {
        hoursDate.setDate(hoursDate.getDate() - 3);
    } else {
        hoursDate.setDate(hoursDate.getDate() - 1);
    }

    // Skip if its sat or sun
    if (hoursDate.getDay() == 0 || hoursDate.getDay() == 7) {
        return null;
    }

    var month = hoursDate.getMonth() + 1;
    var day   = hoursDate.getDate();
    var year  = hoursDate.getFullYear();
 
    return month + '-' + day + '-' + year;
}

// Last week
function getLastWeek() {
    var lastWeek = [
        Date.mon().last().mon().toString(dateFormat),
        Date.tue().last().tue().toString(dateFormat),
        Date.wed().last().wed().toString(dateFormat),
        Date.thu().last().thu().toString(dateFormat),
        Date.fri().last().fri().toString(dateFormat),
    ];
    
    return lastWeek;
}

// This week
function getThisWeek() {
    var thisWeek = [
        Date.mon().toString(dateFormat),
        Date.tue().toString(dateFormat),
        Date.wed().toString(dateFormat),
        Date.thu().toString(dateFormat),
        Date.fri().toString(dateFormat),
    ];
    
    return thisWeek;
}

// Get the engineer list who havent added their hours yet for some date
function getMissingEngineers(hoursDate, callback) {
    var engineerList = new Array();
    // See who it matches
    
    db.open(function(err, db) {
        if (!err) {
            db.collection('hours', function(err, collection) {
                // Get everyone that sent in hours for this date
                collection.find({date : hoursDate}, {'name' : 1}).toArray(function(err, items) {
                    
                    // Now compare and add missing
                    engineers.forEach(function(engineer) {
                        var found = false;
                        
                        items.forEach(function(item){
                            if (item.name == engineer.name) {
                                found = true;
                            }
                        });
                        
                        if (found == false) {
                            engineerList.push(engineer.name);
                        }
                    });
                    
                    // Shut it down
                    db.close();

                    callback(engineerList);
                });
            });
        }
    });
}

// Calculate last weeks average time per engineer, Only works on mondays!
function getWeekAvg(week, callback) {
    db.open(function(err, db) {
        if (!err) {
            db.collection('hours', function(err, collection) {
                // Get everyone that sent in hours for this date
                collection.find({'date' : {'$in' : week}}).toArray(function(err, items) {
                    var hours = [];
                    
                    items.forEach(function(item) {
                        var name = item.name;
                        
                        engineers.forEach(function(engineer) {
                            if (typeof hours[engineer.name] == 'undefined') {
                                hours[engineer.name] = {'name' : engineer.name};
                            }
                            
                            if (name == engineer.name) {
                                if (typeof hours[name].count == 'undefined') {
                                    hours[name].count = 1;
                                } else {
                                    hours[name].count++;
                                }
                                
                                if (item.hours == 'ignore') {
                                    hours[name].count--;
                                } else {
                                    if (typeof hours[name].hours == 'undefined') {
                                        hours[name].hours = parseInt(item.hours);
                                    } else {
                                        hours[name].hours += parseInt(item.hours);
                                    }
                                }
                            }
                        });
                    });
                    
                    var weekAvg = {
                        hours: 0, people : 0
                    };
                    
                    // Now go back over the count and total and make avgs
                    engineers.forEach(function(engineer) {
                        // No hours all week, so forget this guy
                        if (typeof hours[engineer.name].hours == 'undefined' || typeof hours[engineer.name].count == 'undefined') {
                            hours[engineer.name].avg     = 'No hours';
                            hours[engineer.name].weekAvg = 'No hours';
                        } else {
                            // Set the avg per engineer week, even if they didnt work some days
                            hours[engineer.name].avg = Math.ceil(hours[engineer.name].hours / hours[engineer.name].count);   
                            hours[engineer.name].weekAvg = (hours[engineer.name].avg * 5);
                            
                            weekAvg.hours += hours[engineer.name].weekAvg;
                            weekAvg.people++;
                        }
                    });
                    
                    // Shut it down
                    db.close();

                    callback(hours, Math.ceil(weekAvg.hours / weekAvg.people));
                });
            });
        }
    });
}

// Get all totals per person for the given week, no averaging
function getWeekTotals(week, callback) {
    db.open(function(err, db) {
        if (!err) {
            db.collection('hours', function(err, collection) {
                // Get everyone that sent in hours for this date
                collection.find({'date' : {'$in' : week}}).toArray(function(err, items) {
                    var hours = [];
                    
                    items.forEach(function(item) {
                        var name = item.name;
                        
                        engineers.forEach(function(engineer) {
                            if (typeof hours[engineer.name] == 'undefined') {
                                hours[engineer.name] = {'name' : engineer.name};
                            }
                            
                            if (name == engineer.name) {
                                if (typeof hours[name].hours == 'undefined') {
                                    hours[name].hours = parseInt(item.hours);
                                } else {
                                    hours[name].hours += parseInt(item.hours);
                                }
                            }
                        });
                    });
                    
                    if (hours.length > 0) {
                        // Now go back over the count and total and make avgs
                        engineers.forEach(function(engineer) {
                            // No hours all week, so forget this guy
                            if (typeof hours[engineer.name].hours == 'undefined') {
                                hours[engineer.name].hours = 'No hours';
                            }
                        });
                    }
                    
                    // Shut it down
                    db.close();

                    callback(hours);
                });
            });
        }
    });
}

function isEngineerInRoom(name) {
    var returnVal = false;
    
    engineers.forEach(function(engineer) {
        if (engineer.name == name && engineer.inRoom == true) {
            returnVal = true;
        }
    });
    
    return returnVal;
}

// Ask for hours for engineers who havent added them
function askForHours() {
    getMissingEngineers(getYesterday(), function(engineerList) {
        var notifyList = [];
        // Reconcile the missing engineers with who is in the channel, only notify people who are here
        engineerList.forEach(function(engineer) {
            if (isEngineerInRoom(engineer) == true) {
                notifyList.push(engineer);
            }
        });
        
        if (notifyList.length > 0) {
            client.say(ircRoom, notifyList.join(', ') + ' - engineering hours for yesterday');
        }
    });
}

// Start the client
client.connect(null, function() {
    // Reminder crons
    new cronJob('00 45 9 * * 2-6', function(){askForHours()}, null, true);
    new cronJob('00 */10 10-12 * * 2-6', function(){askForHours()}, null, true);
    new cronJob('00 * * * * 2-6', function(){client.send('NAMES', ircRoom)}, null, true);
});

###