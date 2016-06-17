class AccountsController < ApplicationController
  def index
    render locals: { accounts: Datacenter.current.accounts }
  end
end
