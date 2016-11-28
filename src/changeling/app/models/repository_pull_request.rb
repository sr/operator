class RepositoryPullRequest
  def initialize(payload)
    @payload = payload
  end

  def open
    multipass = Multipass.find_or_initialize_by_pull_request(@payload)
    multipass.synchronize_testing_status

    if referenced_ticket
      update_ticket_reference(multipass, referenced_ticket)
    else
      remove_ticket_reference(multipass)
    end

    multipass
  end

  private

  def remove_ticket_reference(multipass)
    if multipass.ticket_reference
      multipass.ticket_reference.destroy!
    end
  end

  def update_ticket_reference(multipass, ticket)
    if ticket.new_record?
      raise ArgumentError, "ticket is a new record"
    end

    if !multipass.ticket_reference
      TicketReference.create!(multipass_id: multipass.id, ticket_id: ticket.id)
    else
      multipass.ticket_reference.update!(ticket_id: ticket.id)
    end

    multipass.save!
  end

  def referenced_ticket
    case @payload["pull_request"]["title"]
    when /\A([A-Z]+\-[0-9]+)/
      Ticket.where(external_id: Regexp.last_match(1), tracker: Ticket::TRACKER_JIRA).first
    end
  end
end
