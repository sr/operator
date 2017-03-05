$(function(){
  /**********************************************/

  $('[data-toggle="tooltip"]').tooltip()
  $('[data-toggle="popover"]').popover()
  /**********************************************/

  $(".edit-backout-plan").click(function() {
    $("#multipass_backout_plan").show()
    $("#multipass_backout_plan").removeClass("hidden")
    $(".backout-plan .markdown").hide()
    $(".backout-plan .edit-backout-plan").hide()
  });

  $('.unique_actor input:checkbox').change(function() {
    if (this.checked) {
      $(this).siblings('.byline').show()
    } else {
      $(this).siblings('.byline').hide()
    }
  })

  $('#impacts_and_probabilities input').on("change", function() {
    calculateRisk()
  })

  function calculateRisk(){
    var textToIndex = {
      "low":    0,
      "medium": 1,
      "high":   2
    }
    var riskMatrix = [
      ["low", "low", "medium"],
      ["low", "medium", "high"],
      ["medium", "high", "high"]
    ]
    // get the expected impact
    var impact = $("input[name='multipass[impact]']:checked").val()
    var impactIndex      = textToIndex[impact]
    // get the impact probability
    var likelihood = $("input[name='multipass[impact_probability]']:checked").val()
    var likelihoodIndex  = textToIndex[likelihood]

    // set the risk (should be shown on form)
    var risk = riskMatrix[impactIndex][likelihoodIndex]
    if (risk) {
      var riskToChangeType = {
        "low":    "minor",
        "medium": "minor",
        "high":   "major"
      }
      var changeType = riskToChangeType[risk]
      $("input[name='multipass[change_type]'][value='" + changeType + "']").parent().click()//.prop("checked", true)
    }
  }

  $(".change_type").change(function() {
    // Show or hide things
    var changeType = $("input[name='multipass[change_type]']:checked").val()
    switch (changeType) {
      case "minor":
        $(".checkbox.peer_reviewer").removeClass("hidden")
        break
      case "major":
        $(".checkbox.peer_reviewer").removeClass("hidden")
        $(".checkbox.sre_approver").removeClass("hidden")
        break
      case "emergency":
        $(".checkbox.peer_reviewer").addClass("hidden")
        $(".checkbox.sre_approver").addClass("hidden")
        break
    }
  })

})
