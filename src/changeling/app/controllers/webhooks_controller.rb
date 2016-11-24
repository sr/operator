# Controller that receives GitHub webhooks events
class WebhooksController < ApplicationController
  before_action :verify_incoming_webhook_address!, :verify_signature!, except: [:jira]
  skip_before_action :verify_authenticity_token, only: [:create, :jira]
  skip_before_action :require_oauth, only: [:create, :jira]

  def jira
    payload = JSON.parse(request.body.read.force_encoding("utf-8"))
    Raven.extra_context(payload: payload)

    event = JIRAIssueEvent.parse(payload)
    Ticket.synchronize_jira_ticket(event)

    render json: {}, status: :created
  end

  def create
    if valid_events.include? event_type
      handle_webhook
      render :json => {}, :status => :created
    else
      render :json => {}, :status => :unprocessable_entity
    end
  end

  def handle_webhook
    case event_type
    when "issue_comment"
      handle_issue_comment
    when "pull_request"
      handle_pull_request
    when "status"
      handle_status
    when "pull_request_review"
      handle_pull_request_review
    end
  end

  def handle_issue_comment
    request.body.rewind
    IssueCommentHandler.perform_later(
      request.headers["HTTP_X_GITHUB_DELIVERY"],
      request.body.read.force_encoding("utf-8")
    )
  end

  def handle_pull_request
    request.body.rewind
    PullRequestHandler.perform_later(
      request.headers["HTTP_X_GITHUB_DELIVERY"],
      request.body.read.force_encoding("utf-8")
    )
  end

  def handle_pull_request_review
    request.body.rewind
    PullRequestReviewHandler.perform_later(
      request.headers["HTTP_X_GITHUB_DELIVERY"],
      request.body.read.force_encoding("utf-8")
    )
  end

  def handle_status
    request.body.rewind
    StatusHandler.perform_later(
      request.headers["HTTP_X_GITHUB_DELIVERY"],
      request.body.read.force_encoding("utf-8")
    )
  end

  def event_type
    request.headers["HTTP_X_GITHUB_EVENT"]
  end

  def valid_events
    %w{issue_comment ping pull_request status pull_request_review}
  end

  private

  def verify_incoming_webhook_address!
    source_ips = Changeling.config.github_source_ips

    if Rails.env.development?
      source_ips << "127.0.0.1/32"
    end

    verified = source_ips.any? { |block| IPAddr.new(block).include?(request.ip) }
    if verified
      true
    else
      render :json => {}, :status => :forbidden
    end
  end

  def signature_for_payload(payload)
    hex = OpenSSL::HMAC.hexdigest(
      OpenSSL::Digest.new("sha1"),
      ENV["GITHUB_WEBHOOK_SECRET"],
      payload
    )
    "sha1=#{hex}"
  end

  def signature_verification_enabled?
    ENV["GITHUB_WEBHOOK_SECRET"] && request.headers["HTTP_X_HUB_SIGNATURE"]
  end

  def verify_signature!
    return true unless signature_verification_enabled?

    request.body.rewind
    signature = signature_for_payload(request.body.read)

    verified = ActiveSupport::SecurityUtils.secure_compare(
      signature,
      request.headers["HTTP_X_HUB_SIGNATURE"]
    )
    return true if verified

    report_unverified_signature
    render :json => {}, :status => :forbidden
  end

  def report_unverified_signature
    Rollbar.error WebhookSignatureValidationError.new("Failed to verify webhook payload signature.")
  end
  class WebhookSignatureValidationError < ArgumentError; end

  def event_params
    params.permit!
  end
end
