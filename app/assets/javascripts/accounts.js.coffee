# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
ready = ->
  $("#account_id").on "change", ->
    return if $(this).val() == ""
    window.location="/accounts/"+$(this).val()+"/queries/new"

$(document).ready(ready)
$(document).on('page:load', ready)