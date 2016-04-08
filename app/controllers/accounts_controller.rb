class AccountsController < ApplicationController
  def index
    database = datacenter.global
    accounts = database.global_accounts

    render locals: {accounts: accounts.all}
  end

  private

  def datacenter
    if params[:datacenter].present?
      DataCenter.find(query_params[:datacenter])
    else
      DataCenter.default
    end
  end

  def params
    super.permit(:datacenter)
  end
end
