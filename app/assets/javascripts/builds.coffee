$ ->
  $("#start-build-in-bamboo-button").on "click", (e) ->
    e.preventDefault()

    button = $(this)
    return if $(button).prop("disabled")

    button.prop("disabled", true)
      .html("<i class=\"icon-spinner\"></i> Enqueuing Build in Bamboo")

    req = $.post button.prop("href")
    req.done (resp) ->
      console.log resp

      bambooBuildUrl = "https://bamboo.dev.pardot.com/browse/#{resp.plan_key}"
      bambooLink = $("<a>")
        .prop("href", bambooBuildUrl)
        .text(bambooBuildUrl)

      button.replaceWith(
        $("<p>")
          .html("<i class=\"icon-spinner\"></i> Bamboo build in progress: ")
          .append(bambooLink)
      )

    req.error (resp) =>
      console.log resp

      button.replaceWith(
        $("<p>")
          .text("Bamboo Build failed to queue. Please contact the Build & Automate team for assistance.")
      )
