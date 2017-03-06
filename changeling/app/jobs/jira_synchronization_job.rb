class JiraSynchronizationJob < ActiveJob::Base
  queue_as :default

  def perform(payload)
    Ticket.synchronize_jira_ticket(payload.fetch("issue").fetch("key"))
  end
end
