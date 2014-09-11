module QueriesHelper
  def query_form_path
    @query.account? ? 
      (@query.id ? account_query_path(@query.account, @query) : account_queries_path(@query.account))
    : 
      (@query.id ? global_query_path(@query) : global_queries_path)
  end

  def is_active?(type, value, output = " active")
    case type
    when :view
      result = @query.view == value
    when :datacenter
      result = @query.datacenter == value
    end
    result ? output.html_safe : ""
  end

  def table_columns
    @query.connection.columns(@query.extract_table_name(@ast)).map(&:name)
  end
end
