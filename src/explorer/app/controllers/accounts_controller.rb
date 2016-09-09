class AccountsController < ApplicationController
  def index
    structure = GlobalAccount.arel_table

    case params[:q]
    when /\A\d+\z/
      accounts = GlobalAccount.where(id: params[:q].to_i)
    else
      accounts = GlobalAccount.where(structure[:company].matches("%#{params[:q]}%"))
    end
    render locals: { accounts: accounts.paginate(page: params[:page]) }
  end
end
