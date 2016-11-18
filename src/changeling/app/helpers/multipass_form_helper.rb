# Helpers for multipass controller and views
module MultipassFormHelper
  FINISHED_STATES = {
    peer_reviewer: "Peer reviewed",
    sre_approver: "SRE approved",
    emergency_approver: "Emergency override"
  }.freeze

  def unique_actor_label(actor_name)
    finished_state = FINISHED_STATES[actor_name.to_sym]
    actor = @multipass.send(actor_name)
    classes = ["byline"]

    if actor.nil?
      classes << "unfinished"
      byline = "by #{current_user.github_login}"
    else
      byline = "by #{actor}"
    end

    raw("#{finished_state} <span class='#{classes.join(' ')}'>#{byline if byline}</span>")
  end

  def unique_actor_fields(actor:, checked:, visible:)
    fields =  "<div class='#{visible ? '' : 'hidden'} checkbox unique_actor #{actor}'>\n"
    fields << "  <label>\n"

    attributes = { name: "multipass[unique_actors][#{actor}]", class: "multipass-unique-actors-#{actor}]", value: "true" }
    attributes[:checked] = "checked" if checked
    attributes[:disabled] = "disabled"
    attributes = attributes.map { |key, value| "#{key}='#{value}'" }

    fields << "    <input type='checkbox' #{attributes.join(' ')}/>#{unique_actor_label(actor)}"
    fields << "  </label>"
    fields << "</div>"

    raw(fields)
  end

  def checked_by_current_user?(actor_name)
    actor = @multipass.send(actor_name)
    actor && !@multipass.same_actor?(actor_name, current_user.github_login)
  end
end

# Monkey patching the default form builder for radio button support
class BootstrapForm::FormBuilder
  def button(name, value, options = {})
    options[:label_class] = "btn btn-default"
    if object.send(name) == value
      options[:label_class] += " active"
    end

    radio_button name, value, options
  end

  def label_with_info(name, value, popover_content)
    data = {
      container: "body",
      toggle: "popover",
      trigger: "hover",
      html: true,
      placement: "top",
      content: popover_content
    }
    label(name, class: "control-label", data: data) do
      value.html_safe +
        content_tag(:i, "", class: "glyphicon glyphicon-question-sign")
    end
  end
end
