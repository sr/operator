class AccountsController < ApplicationController
  def index
    render locals: { accounts: datacenter.accounts }
  end

  private

  def datacenter
    if params[:datacenter].present?
      current_user.datacenter(params[:datacenter])
    else
      current_user.datacenter
    end
  end

  def params
    super.permit(:datacenter)
  end
end
