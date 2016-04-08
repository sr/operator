class QueriesController < ApplicationController
  before_action :permission_check

  def new
    render "_form", locals: {
      database_name: database.name,
      datacenter_name: datacenter.name,
      tables: database.tables,
      sql_query: sql_query.sql,
      account: account,
    }
  end

  def create
    render :show, locals: {
      results: database.execute(current_user, sql_query),
      query: {
        database_name: database.name,
        datacenter_name: datacenter.name,
        tables: database.tables,
        sql_query: sql_query.sql,
      },
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

  def datacenter
    if query_params[:datacenter].present?
      DataCenter.find(query_params[:datacenter])
    else
      DataCenter.default
    end
  end

  def database
    if params[:account_id].present?
      datacenter.shard(params[:account_id])
    else
      datacenter.global
    end
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
