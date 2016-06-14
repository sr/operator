class AccountsController < ApplicationController
  def index
    render locals: { accounts: DataCenter.current.accounts }
  end
end
