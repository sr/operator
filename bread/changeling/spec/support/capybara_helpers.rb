module CapybaraHelpers
  def enable_fields(*fields)
    fields.each do |field|
      page.find_field(field, disabled: true).base.native.remove_attribute("disabled")
    end
  end
end
