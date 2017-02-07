class TicketReference < ApplicationRecord
  belongs_to :ticket
  belongs_to :multipass
end
