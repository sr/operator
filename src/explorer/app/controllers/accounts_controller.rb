class AccountsController < ApplicationController
  def index
    render locals: { accounts: GlobalAccount.all }
  end
end
