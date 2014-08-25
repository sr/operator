require 'sql-parser'

class QueriesController < ApplicationController
  def search
    parser = SQLParser::Parser.new
    @sql = params[:sql]
    command = @sql.slice(0, @sql.index(';') || @sql.size) # Only 1 command
    
    @ast = parser.scan_str(command)
    tables
    render 'index'
  end

  private

  def tables
    @global_tables = ActiveRecord::Base.connection.tables
    @shard_tables = Shard.tables
  end
end
