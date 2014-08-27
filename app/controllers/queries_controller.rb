require 'sql-parser'

class QueriesController < ApplicationController
  def show
    @query = Query.find(params[:id])
    parser = SQLParser::Parser.new
    command = @query.sql.slice(0, @query.sql.index(';') || @query.sql.size) # Only 1 command
    
    @ast = parser.scan_str(command)
    @result = ActiveRecord::Base.connection.execute(@ast.try(:to_sql)) 
  end

  def create
    @query = Query.new(query_params)
    @query.save
    redirect_to @query
  end

  def update
    # Allows create new entries
    create
  end

  def new
    @query = Query.new(sql: "SELECT * FROM accounts", database: "Shard", datacenter: "Dallas")
  end

  private

  def tables
    @global_tables = ActiveRecord::Base.connection.tables
    @shard_tables = Shard.tables
  end

  def query_params
    params.require(:query).permit(:sql, :database, :datacenter)
  end
end
