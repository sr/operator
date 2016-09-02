class QueriesController < ApplicationController
  before_action :check_account_access

  def new
    query = current_user.queries.new(
      account_id: params[:account_id],
      raw_sql: raw_sql_query,
    )

    render "_form", locals: {
      query: query,
      raw_sql: raw_sql_query
    }
  end

  def show
    query = UserQuery.find(params[:id])

    rate_limit =
      if Rails.env.development? && params[:rate_limited].present?
        FakeRateLimit.new
      else
        current_user.rate_limit
      end

    results =
      if rate_limit.at_limit?
        query.blank
      else
        query.execute(current_user)
      end

    respond_to do |format|
      format.html do
        render :show, locals: {
          current_view: params[:view] || sql_view,
          query: query,
          rate_limit: rate_limit,
          results: results
        }
      end
    end
  end

  def create
    query = create_query(params[:sql], params[:account_id])

    redirect_to "/queries/#{query.id}"
  end

  def all_rows
    previous_query = UserQuery.find(params[:id])
    new_query = create_query(previous_query.raw_sql, previous_query.account_id, true)

    redirect_to "/queries/#{new_query.id}"
  end

  private

  def create_query(sql, account_id, all_rows = false)
    query =
      if !account_id.nil?
        current_user.account_query(sql, account_id)
      else
        current_user.global_query(sql)
      end
byebug
    if all_rows
      query.update(all_rows: true)
    end
    query
  end

  def check_account_access
    if params.key?(:account_id) && !account_access?
      message = "Please request support to account #{params[:account_id]}."
      flash[:error] = message
      redirect_to "/accounts"
    end
  end

  def account_access?
    return true if session[:group] == Rails.application.config.x.full_access_ldap_group
    GlobalAccountAccess.authorized?(params[:account_id])
  end

  def raw_sql_query
    if params[:sql].present?
      params[:sql]
    else
      default_sql_query
    end
  end

  def default_sql_query
    if params[:account_id].present?
      "SELECT * FROM account"
    else
      "SELECT * FROM global_account"
    end
  end
end
