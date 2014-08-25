require 'sql-parser'

class QueriesController < ApplicationController
  def show
    @query = Query.find(params[:id])
    parser = SQLParser::Parser.new
    command = @query.sql.slice(0, @query.sql.index(';') || @query.sql.size) # Only 1 command
    
    @ast = parser.scan_str(command)
    tables
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
    @query = Query.new
  end

  private

  def tables
    @global_tables = ActiveRecord::Base.connection.tables
    @shard_tables = Shard.tables
  end

  def query_params
    params.require(:query).permit(:sql)
  end
end
