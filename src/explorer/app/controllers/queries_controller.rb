class QueriesController < ApplicationController
  rescue_from DataCenter::UnauthorizedAccountAccess do |e|
    message = "Please request engineering access to account #{e.account_id}."
    flash[:error] = message
    redirect_to "/accounts"
  end

  def new
    render "_form", locals: {
      account: account,
      database_name: database.name,
      sql_query: sql_query,
      tables: database.tables
    }
  end

  def create
    render :show, locals: {
      account: account,
      database_name: database.name,
      is_limited: params[:is_limited].present?,
      results: database.execute(sql_query.sql),
      sql_query: sql_query,
      tables: database.tables
    }
  end

  private

  def sql_query
    SQLQuery.parse(raw_sql_query)
  end

  def account
    if query_params[:account_id].present?
      datacenter.find_account(query_params[:account_id])
    end
  end

  def database
    if params[:account_id].present?
      datacenter.shard_for(params[:account_id])
    else
      datacenter.global
    end
  end

  def datacenter
    current_user.datacenter
  end

  def raw_sql_query
    if query_params[:sql].present?
      query_params[:sql]
    else
      default_sql_query
    end
  end

  def default_sql_query
    if query_params[:account_id].present?
      "SELECT * FROM account"
    else
      "SELECT * FROM global_account"
    end
  end

  def query_params
    params.permit(:sql, :database, :view, :account_id, :is_limited)
  end

  def account_params
    params.permit(:account_id)
  end
end
