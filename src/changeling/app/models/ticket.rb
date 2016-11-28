class Ticket < ApplicationRecord
  TRACKER_JIRA = "jira".freeze

  has_one :ticket_reference
  has_one :multipass

  def self.synchronize_jira_ticket(event)
    Ticket.transaction do
      ticket = Ticket.where(external_id: event.issue_key).first

      if ticket
        ticket.update!(summary: event.issue_summary)
      else
        ticket = Ticket.create!(
          external_id: event.issue_key,
          summary: event.issue_summary,
          tracker: Ticket::TRACKER_JIRA
        )
      end

      ticket
    end
  end

  def url
    case tracker
    when TRACKER_JIRA
      "#{Changeling.config.jira_url}/browse/#{external_id}"
    else
      ""
    end
  end
end
