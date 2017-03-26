class HealthController < ApplicationController
  skip_before_action :require_oauth_authentication, only: [:boomtown, :slowloris]

  def slowloris
    sleep Rack::Timeout.service_timeout + 5
  end

  def boomtown
    raise "boomtown"
  end
end
