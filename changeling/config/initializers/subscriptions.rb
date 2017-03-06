require "metrics"

ActiveSupport::Notifications.subscribe("multipass.emergency_override") do |_name, _start, _finish, _id, payload|
  PublishEventJob.perform_later("emergency_override", payload[:multipass])
end

ActiveSupport::Notifications.subscribe("application.release") do |_name, _start, _finish, _id, payload|
  NotifyChatJob.perform_later("deploy", payload[:event])
end

ActiveSupport::Notifications.subscribe("multipass.peer_review") do |*args|
  e = ActiveSupport::Notifications::Event.new(*args)
  from = e.payload[:from]
  Metrics.increment("multipass.peer_review.#{from}")
  Metrics.increment("multipass.peer_review")
end
