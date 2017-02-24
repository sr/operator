shellquote = require "shell-quote"
_ = require "underscore"

module.exports =
  parse: (str) ->
    shellquote.parse(str).map (obj) ->
      if _.isObject(obj)
        obj.op
      else
        obj
