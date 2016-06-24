class AccountsController < ApplicationController
  def index
    render locals: { accounts: GlobalAccount.paginate(:page => params[:page]) }
  end
end
