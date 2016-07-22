class AccountsController < ApplicationController
  def index
    structure = GlobalAccount.arel_table
    accounts = GlobalAccount.where(structure[:company].matches("%#{params[:q]}%")).paginate(page: params[:page])
    render locals: { accounts: accounts }
  end
end
