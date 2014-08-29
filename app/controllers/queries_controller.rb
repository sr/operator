require 'sql-parser'

class QueriesController < ApplicationController
  def show
    @query = Query.find(params[:id])
    parser = SQLParser::Parser.new
    command = @query.sql.slice(0, @query.sql.index(';') || @query.sql.size) # Only 1 command
    
    @ast = parser.scan_str(command)
    @result = @query.execute(@ast.try(:to_sql)) 
  end

  def create
    @query = Query.new(query_params)
    @query.account_id = account_params[:account_id]
    
    if @query.save
      redirect_to @query.account? ? account_query_path(@query.account, @query) : global_query_path(@query)
    else
      render :new
    end
  end

  def update
    # Allows create new entries
    create
  end

  def new
    defaults = {sql: "SELECT * FROM global_account", datacenter: "Dallas"}
    if account_params[:account_id]
      # Accounts query
      @query = Query.new(defaults.merge(database: "Account", account_id: account_params[:account_id]))
    else
      # Global query
      @query = Query.new(defaults.merge(database: "Global"))
    end
  end

  private

  def query_params
    params.require(:query).permit(:sql, :database, :datacenter, :account_id)
  end

  def account_params
    params.permit(:account_id)
  end
end
