# Handle status webhooks from GitHub
class StatusHandler < ActiveJob::Base
  def perform(_delivery, data)
    payload = JSON.parse(data)

    user = User.find_by(github_login: payload["sender"]["login"])
    Audited::Audit.as_user(user) do
      CommitStatus.new(payload).update_multipass_testing
    end
  end
end
