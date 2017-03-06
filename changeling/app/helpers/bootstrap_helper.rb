# Helper methods to generate bootstrap elements
module BootstrapHelper
  def tooltip(message)
    attributes = {
      class: "helper-text",
      title: message,
      "data-toggle": "tooltip",
      "data-placement": "right",
      "data-delay": '{"show":"500", "hide":"100"}'
    }

    content_tag(:span, attributes) do
      yield
    end
  end
end
