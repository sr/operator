class AccountsController < ApplicationController
  def index
    render locals: { accounts: datacenter.global_accounts }
  end
end
