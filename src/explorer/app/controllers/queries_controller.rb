class QueriesController < ApplicationController
  rescue_from DataCenter::UnauthorizedAccountAccess do |e|
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

    respond_to do |format|
      format.html do
        render :show, locals: {
          current_view: params[:view] || Query::SQL,
          query: query,
          results: query.execute
        }
      end
      format.csv do
        render text: query.execute_csv
      end
    end
  end

  def create
    query = current_user.queries.create!(
      account_id: params[:account_id],
      raw_sql: params[:sql]
    )

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
