class QueriesController < ApplicationController
  before_filter :check_account_access

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
    query =
      if params[:account_id].present?
        current_user.account_query(params[:sql], params[:account_id])
      else
        current_user.global_query(params[:sql])
      end

    redirect_to "/queries/#{query.id}"
  end

  private

  def check_account_access
    if params.has_key?(:account_id) && !account_access?
      message = "Please request engineering access to account #{params[:account_id]}."
      flash[:error] = message
      redirect_to "/accounts"
    end
  end

  def account_access?
    return true if session[:group] == User::FULL_ACCESS

    query = <<-SQL.freeze
      SELECT id FROM global_account_access
      WHERE role = ? AND account_id = ? AND (expires_at IS NULL OR expires_at > NOW())
      LIMIT 1
    SQL

    results = DataCenter.current.global.execute(query, [Rails.application.config.x.support_role, params[:account_id]])
    results.size == 1
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
