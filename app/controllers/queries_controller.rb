require 'sql-parser'

class QueriesController < ApplicationController
  before_action :permission_check

  def new
    defaults = {datacenter: DataCenter::DALLAS, view: Query::SQL}
    if account_params[:account_id]
      # Accounts query
      @query = Query.new(defaults.merge(sql: "SELECT * FROM account", database: Database::SHARD, account_id: account_params[:account_id]))
    else
      # Global query
      @query = Query.new(defaults.merge(sql: "SELECT * FROM global_account", database: Database::GLOBAL))
    end
  end

  def create
    @query = Query.new(query_params)
    @query.account_id = account_params[:account_id]
    @result = @query.execute(current_user, "")

    render :show
  end

  private

  def query_params
    params.permit(:sql, :database, :datacenter, :view, :account_id, :is_limited)
  end

  def account_params
    params.permit(:account_id)
  end

  def permission_check
    account = account_params[:account_id]
    if account
      unless Account.find(account).access?
        flash[:error] = "Please request engineering access to account #{account}."
        redirect_to accounts_path
      end
    else
      true
    end
  end
end
