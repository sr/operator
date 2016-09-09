class AccountsController < ApplicationController
  def index
    structure = GlobalAccount.arel_table
    account_id = begin
      Integer(params[:q])
    rescue ArgumentError
      false
    end

    if account_id
      accounts = GlobalAccount.where(id: account_id)
    else
      accounts = GlobalAccount.where(structure[:company].matches("%#{params[:q]}%"))
    end
    render locals: { accounts: accounts.paginate(page: params[:page]) }
  end
end
