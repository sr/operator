class JIRATicket
  OPEN_STATUSES = [
    "Accepted",
    "Backlog",
    "Blocked",
    "In Progress",
    "Investigation",
    "To Do",
    "Under Consideration",
    "Under Review",
    "QA",
    "QA Confirmed",
    "QA In Progress",
    "Reopened",
    "Waiting on Client"
  ].freeze

  def initialize(ticket)
    @ticket = ticket
  end

  def open?
    OPEN_STATUSES.include?(@ticket.status)
  end

  def url
    "#{Changeling.config.jira_url}/browse/#{@ticket.external_id}"
  end
end
