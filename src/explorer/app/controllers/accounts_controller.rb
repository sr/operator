class AccountsController < ApplicationController
  def index
    render locals: { accounts: DataCenter.current.global_accounts }
  end
end
