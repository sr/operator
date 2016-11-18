require "metrics"

ActiveSupport::Notifications.subscribe("multipass.emergency_override") do |_name, _start, _finish, _id, payload|
  PublishEventJob.perform_later("emergency_override", payload[:multipass])
end

ActiveSupport::Notifications.subscribe("application.release") do |_name, _start, _finish, _id, payload|
  NotifyChatJob.perform_later("deploy", payload[:event])
end

ActiveSupport::Notifications.subscribe("multipass.completed") do |_name, _start, _finish, _id, payload|
  multipass = payload[:multipass]
  Metrics.increment("multipasses.completed.#{multipass.loggable_repository_name}", prepend_source: false)
  Metrics.increment("multipasses.completed", prepend_source: false)
  if multipass.changed_risk_assessment?
    Metrics.increment("multipass.risk-assessment.changed")
  else
    Metrics.increment("multipass.risk-assessment.unchanged")
  end
end

ActiveSupport::Notifications.subscribe("multipass.peer_review") do |*args|
  e = ActiveSupport::Notifications::Event.new(*args)
  from = e.payload[:from]
  Metrics.increment("multipass.peer_review.#{from}")
  Metrics.increment("multipass.peer_review")
end

ActiveSupport::Notifications.subscribe(/process_action.action_controller/) do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  status = event.payload[:status] || ActionDispatch::ExceptionWrapper.new({}, event.payload[:exception_object]).status_code
  state = case status.to_s[0]
          when "2" then "success"
          when "3" then "redirection"
          when "4" then "error"
          when "5" then "failure"
          else "unknown"
          end
  Metrics.increment("requests.#{state}")
end
