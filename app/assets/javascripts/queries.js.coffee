# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $(".sideoption a").on "click", (e) ->
    e.preventDefault()
    $(this).toggle().siblings().toggle().parent().siblings().children().toggle()
    if $(this).parent().parent().hasClass("database")
      $("#account_id").css('display', $("#shard_selected").css('display'))
    
  $(".view > button").on "click", ->
    return if $(this).hasClass("active")
    $(this).addClass("active").siblings().removeClass("active")
    $(".viewoption").toggle()

  $(".account_helper").on "click", (e) ->
    e.preventDefault()
    $("#query_sql").val("SELECT * FROM `"+$(this).html()+"`")
    $('form').submit()