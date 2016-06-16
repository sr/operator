class WelcomeController < ApplicationController
  skip_before_action :require_oauth_authentication, only: :boomtown

  def index
  end

  def boomtown
    raise "boomtown"
  end

  def version
    render layout: false
  end
end
