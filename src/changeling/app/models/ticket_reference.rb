class TicketReference < ApplicationRecord
  belongs_to :ticket
  belongs_to :multipass

  def open?
    ticket.open?
  end

  def ticket_id
    ticket.external_id
  end

  def ticket_url
    ticket.url
  end
end
