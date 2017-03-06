# Helpers to offload some markup generation logic from the actor form.
module ActorFormHelper
  BUTTON_CLASS = "btn btn-lg".freeze

  APPROVE_TEXT_FOR_FIELD = {
    peer_reviewer: "Peer Review",
    sre_approver: "SRE Approve",
    rejector: "Reject",
    emergency_approver: "Override!"
  }.freeze

  REMOVE_TEXT_FOR_FIELD = {
    peer_reviewer: "Remove Peer Review",
    sre_approver: "Remove SRE Approval",
    rejector: "Rejected",
    emergency_approver: "Remove Override"
  }.freeze

  ENABLED_CLASSES = {
    rejector: "#{BUTTON_CLASS} btn-danger",
    emergency_approver: "#{BUTTON_CLASS} btn-danger"
  }.freeze

  DISABLED_CLASSES = {
  }.freeze

  def class_for_new_actor_button(field, multipass)
    disabled_class = DISABLED_CLASSES[field.to_sym] || "#{BUTTON_CLASS} disabled"

    return disabled_class if disabled_new_actor?(field, multipass)

    button_class = ENABLED_CLASSES[field.to_sym] || "#{BUTTON_CLASS} btn-success"
    button_class += " btn-default locking-button" if multipass.locking_field?(field, 2)

    button_class
  end

  def disabled_new_actor?(field, multipass)
    multipass.complete? || !multipass.enabled_actor?(field, 2) || multipass.rejector? || multipass.emergency_approver?
  end

  def new_actor_button(field, multipass)
    disabled = if multipass.complete?
                 true
               elsif multipass.enabled_actor?(field, 2) && !multipass.rejector?
                 false
               else
                 true
               end

    button = submit_tag(
      APPROVE_TEXT_FOR_FIELD[field.to_sym],
      class: class_for_new_actor_button(field, multipass),
      disabled: disabled
    )

    icon = content_tag(:span, "", class: "fa fa-lock actor-lock-icon", id: "#{field}-lock-icon")
    locked = content_tag(:span, " Locked", class: "locked-text")
    "#{button}#{(icon + locked) if multipass.locking_field?(field, 2)}".html_safe
  end

  def existing_actor_button(field, multipass, current_user)
    if !multipass.same_actor?(field, current_user.github_login) || multipass.rejector?
      disabled = true
      button_class = DISABLED_CLASSES[field.to_sym] || "#{BUTTON_CLASS} disabled"
    else
      disabled = false
      button_class = ENABLED_CLASSES[field.to_sym] || BUTTON_CLASS.to_s
    end

    button_class += " existing-actor"

    text = REMOVE_TEXT_FOR_FIELD[field.to_sym]
    submit_tag(text, class: button_class, disabled: disabled)
  end

  def unnecessary_field?(field, multipass)
    field != "rejector" && field != "emergency_approver" && !multipass.required_field?(field)
  end

  def url_for_field(field, multipass)
    case field
    when "peer_reviewer"
      review_multipass_path(multipass)
    when "sre_approver"
      sre_approve_multipass_path(multipass)
    when "emergency_approver"
      emergency_multipass_path(multipass)
    when "rejector"
      reject_multipass_path(multipass)
    end
  end
end
