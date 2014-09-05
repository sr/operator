# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
ready = ->
  $(".view > button").on "click", ->
    $t = $(this)
    return if $t.hasClass("active")
    $t.addClass("active").siblings().removeClass("active")
    $(".viewoption").toggle()
    $("#query_view").val($t.attr('data-val'))

  $(".datacenter > button").on "click", ->
    $t = $(this)
    return if $t.hasClass("active")
    $t.addClass("active").siblings().removeClass("active")
    $("#query_datacenter").val($t.attr('data-val'))

  $(".account_helper").on "click", (e) ->
    e.preventDefault()
    $("#query_sql").val("SELECT * FROM `"+$(this).html()+"`")
    $("#query_is_limited").val("true")
    $('form').submit()

  $(".all_rows").on "click", (e) ->
    e.preventDefault()
    $("#query_is_limited").val("false")
    $('form').submit()

$(document).ready(ready)
$(document).on('page:load', ready)