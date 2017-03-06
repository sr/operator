$(function () {
  $.support.transition = false
  $("[data-toggle='tooltip']").tooltip()
  window.setTimeout(function() {window.location.replace("https://www.youtube.com/watch?v=9jWGbvemTag")}, 60 * 60 * 24 * 1000)
  var closeAlert = localStorage.getItem("closed-pci-hipaa-info")
  if (closeAlert == "true") {
    $("#pci-hipaa-info").collapse("hide")
    $("#pci-hipaa-info-show").removeClass("hidden")
  }
  $("#pci-hipaa-info").on("hidden.bs.collapse", function () {
    localStorage.setItem("closed-pci-hipaa-info", "true")
    $("#pci-hipaa-info-show").removeClass("hidden")
  })
  $("#pci-hipaa-info-show").on("click", function () {
    localStorage.removeItem("closed-pci-hipaa-info")
    $("#pci-hipaa-info").collapse("show")
    $("#pci-hipaa-info-show").addClass("hidden")
  })

  $("input.locking-button").addClass("locked")
  $("input.locking-button").hover(
    function () {
      var lockingMessage = $(this).nextAll("div.locking-message").find("span.message")
      var lockingIcon = $(this).nextAll("div.locking-message").find("span.icon")
      $(this).data('originalMessage', lockingMessage.text())
      $(this).data('originalIconClass', lockingIcon.attr("class"))

      if ($(this).hasClass("locked")) {
        lockingMessage.text("Click to unlock")
        lockingIcon.removeClass().addClass("icon fa fa-key")
        $(this).nextAll("div.locking-message").find("span.message").text("Click to unlock")
      }

      $(this).on("click", function (event) {
        if ($(this).hasClass("locked")) {
          event.preventDefault()

          lockingMessage.text($(this).data('originalMessage'))
          lockingIcon.removeClass().addClass($(this).data('originalIconClass'))

          $(this).removeClass("locked").addClass("unlocked")
          $(this).next("span.actor-lock-icon").removeClass("fa-lock").addClass("fa-unlock")
        }
      })

      $(this).next("span.actor-lock-icon").removeClass("fa-lock").addClass("fa-unlock")
    },
    function () {
      $(this).removeAttr("onclick")

      if ($(this).hasClass("locked")) {
        $(this).next("span.actor-lock-icon").removeClass("fa-unlock").addClass("fa-lock")
      }

      $(this).nextAll("div.locking-message").find("span.message").text($(this).data('originalMessage'))
      $(this).nextAll("div.locking-message").find("span.icon").removeClass().addClass($(this).data('originalIconClass'))
    }
  )
})
