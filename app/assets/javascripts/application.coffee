# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file.
#
# Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
# about supported directives.
#
#= require jquery
#= require jquery_ujs
#= require jquery_nested_form
#= require bootstrap-sprockets
#= require_tree .

window.isProduction = ->
  window.location.host == "canoe.pardot.com"

$ ->
  $("#include-untested-build-form input").on "change", (e) ->
    checkbox = $(this)
    form = $(this).closest("form")

    if checkbox.prop("checked")
      if !window.isProduction() or confirm("Untested builds should only be deployed in emergency situations. Are you sure?")
        form.submit()
        form.find("input").prop("disabled", true)
      else
        checkbox.prop("checked", false)
    else
      form.submit()
      form.find("input").prop("disabled", true)

  if $('.shipithere') && $('.repo').text().match(/pardot/)
    if $('h2 > span').text().match(/derweze/i)
      $('.shipithere[data-target="production"]').attr("disabled", true)
    else
      $('.shipithere[data-target="production_dfw"]').attr("disabled", true)
