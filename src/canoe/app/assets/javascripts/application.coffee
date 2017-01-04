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
#= require underscore
#= require jquery
#= require jquery_ujs
#= require jquery_nested_form
#= require bootstrap-sprockets
#= require selectize
#= require handlebars
#= require alpaca
#= require_tree .

$ ->
  $("#allow-failed-builds-form input").on "change", (e) ->
    checkbox = $(this)
    form = $(this).closest("form")

    if checkbox.prop("checked")
      if confirm("Failed builds should only be deployed in emergency situations. Are you sure?")
        form.submit()
        form.find("input").prop("disabled", true)
      else
        checkbox.prop("checked", false)
    else
      form.submit()
      form.find("input").prop("disabled", true)

  $("#server_server_tag_names").selectize
    create: true
    hideSelected: true

  $("input[name='server_tags[]']").on "change", (e) ->
    $checkbox = $(this)
    checked = $checkbox.is(":checked")

    for hostname in $checkbox.data("server-hostnames")
      $("input[name='server_hostnames[]'][value='#{hostname}']").prop("checked", checked)
