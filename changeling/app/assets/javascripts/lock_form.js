clicked = null
$(function(){
  if ($("input").length > 0) {
    function activateHelpFor(target){
      var container = target.closest(".help-text-container")
      var name = target.find("input").attr("value")

      container.find("span.helptext").removeClass('active')
      container.find("span.helptext." + name).addClass('active')
    }

    $.each($("input:checked"), function(_index, button){
      activateHelpFor($(button).closest(".radio-inline"))
    })

    $(".help-text-container").find(".radio-inline").click(function() {
      activateHelpFor($(this))
    })

    $(window).load(function(){
      var lockingButtons = $("input.locking-button")

      lockingButtons.off("mouseenter mouseleave")

      lockingButtons.click(function(){
        var button = $(this)

        if (button.hasClass("locked")){
          event.preventDefault()
          var buttonText = $(this).val()

          button.removeClass("btn-default")
          button.val("Confirm " + buttonText)

          var lockIcon = button.nextAll("span.actor-lock-icon")
          lockIcon.removeClass("fa-lock").addClass("fa-unlock")

          var lockedText = button.nextAll("span.locked-text")
          lockedText.text("Unlocked")

          var unlockMessage = button.nextAll("span.unlock-message")
          unlockMessage.html("<a href='#' class='cancel-unlock'>Cancel</a>")

          button.removeClass("locked")

          unlockMessage.find("a.cancel-unlock").click(function(){
            event.preventDefault()

            button.val(buttonText)
            button.addClass("btn-default")
            lockIcon.removeClass("fa-unlock").addClass("fa-lock")
            unlockMessage.html("Click to unlock")
            lockedText.text("Locked")

            button.addClass("locked")
          })
        } else {
          button.removeClass("btn-default")
        }
      })
    })
  }
})
