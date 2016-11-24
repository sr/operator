class TicketReference < ApplicationRecord
  belongs_to :ticket
  belongs_to :multipass

  def ticket_id
    ticket.external_id
  end

  def ticket_url
    ticket.url
  end
end
