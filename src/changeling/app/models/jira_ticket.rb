class JIRATicket
  OPEN_STATUSES = ["Under Consideration", "To Do"].freeze

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
