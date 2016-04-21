module ApplicationHelper
  def active?(type, value, output = " active")
    result = params[type] == value
    result ? output.html_safe : ""
  end

  def table_columns
    @query.connection.columns(@query.extract_table_name(@ast)).map(&:name)
  end
end
