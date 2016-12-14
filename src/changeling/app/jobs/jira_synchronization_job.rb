class JiraSynchronizationJob < ActiveJob::Base
  queue_as :default

  def perform(webhook_payload)
    Raven.extra_context(payload: webhook_payload)
    webhook_issue = JIRAIssue.new(webhook_payload)
    Ticket.synchronize_jira_ticket(webhook_issue.key)
  end
end
