class JiraEventsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]
  skip_before_action :require_oauth, only: [:create]

  cattr_accessor :redis_connection do
    Redis.new(url: ENV["REDIS_URL"])
  end

  def create
    payload = JSON.parse(request.body.read.force_encoding("utf-8"))
    Raven.extra_context(payload: payload)

    event = JIRAIssueEvent.parse(payload)
    redis_connection.sadd("jira-statuses", event.issue_status.inspect)
    Ticket.synchronize_jira_ticket(event)

    render json: {}, status: :created
  end
end
