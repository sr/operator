# Handle status webhooks from GitHub
class StatusHandler < ActiveJob::Base
  def perform(_delivery, data)
    payload = JSON.parse(data)

    user = User.find_by(github_login: payload["sender"]["login"])
    repo = Repository.find(payload["repository"]["full_name"])
    commit_status = Clients::GitHub::CommitStatus.new(
      payload["commit"]["sha"],
      payload["context"],
      payload["state"],
    )
    status = repo.synchronize_commit_status(
      payload["repository"]["id"],
      commit_status
    )

    Audited::Audit.as_user(user) do
      if Changeling.config.pardot?
        Multipass.where(release_id: status.sha).each do |multipass|
          multipass.synchronize_testing_status
        end
      else
        CommitStatus.new(payload).update_multipass_testing
      end
    end
  end
end
