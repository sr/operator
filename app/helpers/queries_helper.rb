module QueriesHelper
  def query_form_path
    @query.account? ? 
      (@query.id ? account_query_path(@query.account, @query) : account_queries_path(@query.account))
    : 
      (@query.id ? global_query_path(@query) : global_queries_path)
  end
end
