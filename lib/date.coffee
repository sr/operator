moment = require "moment-timezone"

module.exports =
  formatDateString: (dateString) ->
    moment(dateString)
      .tz("America/New_York")
      .format('llll z')
