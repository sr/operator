# Helper methods to format flash messages with bootstrap
module FlashHelper
  BOOTSTRAP_CLASS = {
    success: "alert-success",
    error: "alert-danger",
    alert: "alert-warning",
    notice: "alert-success"
  }.freeze

  def bootstrap_class_for(flash_type)
    BOOTSTRAP_CLASS.fetch(flash_type.to_sym, flash_type.to_s)
  end

  def flash_messages(_opts = {})
    messages = ""

    flash.each do |msg_type, message|
      messages << content_tag(:div, message, class: "alert #{bootstrap_class_for(msg_type)} fade in") do
        content_tag(:span, "&times;".html_safe, class: "close", data: { dismiss: "alert" }) + message
      end
    end

    messages.html_safe
  end
end
