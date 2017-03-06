# Process an event Payload and store in the DB
class StreamEventJob < ActiveJob::Base
  queue_as :default

  def perform(event_payload)
    event = Event.new_from_payload(event_payload)
    event.save

    ActiveSupport::Notifications.instrument("events.received", event: event)
    ActiveSupport::Notifications.instrument("application.release", event: event)
  end
end
