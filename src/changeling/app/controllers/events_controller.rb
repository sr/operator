# Controller for creating events from webhooks
# Specifically for Kernel apps and deploymaster
class EventsController < ApplicationController
  before_action :authenticate_service
  skip_before_action :verify_authenticity_token, only: [:create]
  skip_before_action :require_oauth, only: [:create]

  def create
    WebhookEventJob.perform_later(request_body)
    render :json => {}, :status => :accepted
  end

  private

  def request_body
    request.body.rewind
    request.body.read.force_encoding("utf-8")
  end

  def authenticate_service
    unless authenticate_with_http_token { |token, _| token == api_token }
      render :json => {}, :status => :forbidden
    end
    true
  end

  def api_token
    ENV.fetch("WEBHOOK_API_TOKEN")
  end
end
