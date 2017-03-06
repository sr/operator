class TicketReference < ApplicationRecord
  belongs_to :ticket
  belongs_to :multipass

  TICKET_TYPE_STORY = "story".freeze
  TICKET_TYPE_EMERGENCY = "emergency".freeze
end
