class JiraEventsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]
  skip_before_action :require_oauth, only: [:create]

  cattr_accessor :redis_connection do
    Redis.new(url: ENV["REDIS_URL"])
  end

  def create
    # The webhook data cannot be trusted. We use the payload only to get the key
    # to reach back to the JIRA API to get authoritative data.
    webhook_payload = JSON.parse(request.body.read.force_encoding("utf-8"))
    webhook_issue = JIRAIssue.new(webhook_payload)
    Raven.extra_context(payload: webhook_payload)

    payload = Changeling.config.jira_client.Issue.find(webhook_issue.key).attrs
    issue = JIRAIssue.new(payload)
    Ticket.synchronize_jira_ticket(issue)

    render json: {}, status: :created
  end
end
