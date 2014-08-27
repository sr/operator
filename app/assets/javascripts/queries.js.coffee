# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $(".sideoption a").on "click", (e) ->
    e.preventDefault()
    $(this).toggle().siblings().toggle().parent().siblings().children().toggle()
    if $(this).parent().parent().hasClass("database")
      $("#account_id").css('display', $("#shard_selected").css('display'))
    
    