class JiraEventsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]
  skip_before_action :require_oauth, only: [:create]

  def create
    payload = JSON.parse(request.body.read.force_encoding("utf-8"))
    Raven.extra_context(payload: payload)

    event = JIRAIssueEvent.parse(payload)
    Ticket.synchronize_jira_ticket(event)

    render json: {}, status: :created
  end
end
