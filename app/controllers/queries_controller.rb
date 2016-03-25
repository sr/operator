require 'sql-parser'

class QueriesController < ApplicationController
  before_action :permission_check

  def show
    @query = Query.find(params[:id])
    @ast = @query.parse(@query.sql)
    begin
      @result = @query.execute(@ast.try(:to_sql))
    rescue ActiveRecord::StatementInvalid => e
      @query.errors.add :sqlerror, e
      render :new
    end
    @query.access_logs.create(user: "")

    if @query.view == VW::CSV
      render 'show.csv.erb'
    end
  end

  def create
    @query = Query.new(query_params)
    @query.account_id = account_params[:account_id]
    
    if @query.save
      redirect_to @query.account? ? account_query_path(@query.account, @query) : global_query_path(@query)
    else
      render :new
    end
  end

  def update
    # Allows create new entries
    create
  end

  def new
    defaults = {datacenter: DataCenter::DALLAS, view: VW::SQL}
    if account_params[:account_id]
      # Accounts query
      @query = Query.new(defaults.merge(sql: "SELECT * FROM account", database: DB::Account, account_id: account_params[:account_id]))
    else
      # Global query
      @query = Query.new(defaults.merge(sql: "SELECT * FROM global_account", database: DB::Global))
    end
  end

  private

  def query_params
    params.require(:query).permit(:sql, :database, :datacenter, :view, :account_id, :is_limited)
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
