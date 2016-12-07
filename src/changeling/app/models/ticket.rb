class Ticket < ApplicationRecord
  TRACKER_JIRA = "jira".freeze

  has_one :ticket_reference
  has_one :multipass

  def self.synchronize_jira_ticket(issue)
    ticket = Ticket.find_or_initialize_by(
      external_id: issue.key,
      tracker: Ticket::TRACKER_JIRA
    )
    ticket.summary = issue.summary
    ticket.status = issue.status
    ticket.open = issue.open?
    ticket.url = issue.url
    ticket.save!

    ticket
  end
end
