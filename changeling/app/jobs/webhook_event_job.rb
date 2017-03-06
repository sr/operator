# Job for events coming througn the /events endpoint
# These are deploymaster deployments events
#
# {
#   id:,
#   app_name:,
#   resource: "deployment",
#   action:   "create",
#   payload: full stuff
#   user_email: email,
#   release_sha: sha
# }
class WebhookEventJob < ActiveJob::Base
  def perform(body)
    e = JSON.parse(body)
    params = {
      external_id: e["id"],
      app_name:    e["app_name"],
      resource:    "deployment",
      action:      "create",
      release_sha: e["sha"],
      user:        User.for_heroku_email(e["user_email"]),
      multipass:   Multipass.find_by(["release_id LIKE ?", "#{e['sha']}%"]),
      payload:     e
    }

    event = Event.create!(params)
    ActiveSupport::Notifications.instrument("application.release", event: event)
    event
  end
end
