# Publish events to shuriken
class PublishEventJob < ActiveJob::Base
  queue_as :default

  def perform(type, multipass)
    Shuriken.new.publish(type, multipass)
  end
end
