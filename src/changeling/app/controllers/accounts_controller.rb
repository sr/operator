# Controller that handles Your account
class AccountsController < ApplicationController
  def show
  end

  def update
    if current_user.update(user_params)
      flash[:notice] = "Your account was successfuly updated"
    else
      flash[:error] = "Your account was not updated"
    end
    redirect_to account_path
  end

  private

  def user_params
    params.require(:user).permit(:team)
  end
end
