class Ticket < ApplicationRecord
  class UnsupportedTracker < StandardError
    def initialize(tracker)
      super "ticket tracker not supported: #{tracker.inspect}"
    end
  end

  TRACKER_JIRA = "jira".freeze

  has_one :ticket_reference
  has_one :multipass

  def self.synchronize_jira_ticket(event)
    Ticket.transaction do
      ticket = Ticket.where(external_id: event.issue_key).first

      if ticket
        ticket.update!(summary: event.issue_summary, status: event.issue_status)
      else
        ticket = Ticket.create!(
          external_id: event.issue_key,
          summary: event.issue_summary,
          status: event.issue_status,
          tracker: Ticket::TRACKER_JIRA
        )
      end

      ticket
    end
  end

  def open?
    ticket_adapter.open?
  end

  def url
    ticket_adapter.url
  end

  private

  def ticket_adapter
    case tracker
    when TRACKER_JIRA
      JIRATicket.new(self)
    else
      raise UnsupportedTicketTracker, tracker
    end
  end
end
