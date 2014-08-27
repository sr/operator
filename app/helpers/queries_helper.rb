module QueriesHelper
  def show_tag?(type, value, link)
    case type
    when :database
      result = @query.database == value
    when :datacenter
      result = @query.datacenter == value
    end
    result = !result if link == :span
    result ? "style='display: none;'".html_safe : ""
  end
end
