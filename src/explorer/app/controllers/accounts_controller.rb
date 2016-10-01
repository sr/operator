class AccountsController < ApplicationController
  def index
    structure = GlobalAccount.arel_table

    case params[:q]
    when /\A\d+\z/
      accounts = GlobalAccount.where(id: Integer(params[:q]))
    else
      accounts = GlobalAccount.where(structure[:company].matches("%#{params[:q]}%"))
    end
    render locals: { accounts: accounts.paginate(page: params[:page]) }
  end
end
