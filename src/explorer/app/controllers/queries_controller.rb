class QueriesController < ApplicationController
  rescue_from UserQuery::UnauthorizedAccountAccess do |e|
    message = "Please request engineering access to account #{e.account_id}."
    flash[:error] = message
    redirect_to "/accounts"
  end

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
