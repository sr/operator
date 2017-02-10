class WelcomeController < ApplicationController
  skip_before_action :require_oauth_authentication, only: [:boomtown, :version]

  def index; end

  def boomtown
    raise "boomtown"
  end

  def version
    render plain: Rails.application.config.x.build_version
  end
end
