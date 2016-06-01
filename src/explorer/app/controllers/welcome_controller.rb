class WelcomeController < ApplicationController
  skip_before_action :require_oauth_authentication, only: :boomtown

  def index
  end

  def boomtown
    fail "boomtown"
  end
end
