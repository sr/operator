class AccountsController < ApplicationController
  def index
    render locals: { accounts: current_user.global_accounts }
  end
end
