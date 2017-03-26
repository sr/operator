# Notify on chat for events
class NotifyChatJob < ActiveJob::Base
  queue_as :default

  def perform(type, event_payload)
    notifier = Notifiers::Chat.new
    return unless notifier.respond_to?(type)
    notifier.send(type, event_payload)
  end
end
