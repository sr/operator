# Publish events to shuriken
class PublishEventJob < ActiveJob::Base
  queue_as :default

  def perform(type, multipass)
    Shuriken.new.publish(type, multipass)
    return unless type == "emergency_override"
    EmergencyOverrideMailer.send_multipass(multipass).deliver_later
  end
end
