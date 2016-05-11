class AccountsController < ApplicationController
  def index
    render locals: { accounts: datacenter.accounts }
  end

  private

  def datacenter
    current_user.datacenter
  end
end
