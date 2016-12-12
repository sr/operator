# Handle status webhooks from GitHub
class StatusHandler < ActiveJob::Base
  def perform(_delivery, data)
    payload = JSON.parse(data)

    user = User.find_by(github_login: payload["sender"]["login"])
    commit_status = Clients::GitHub::CommitStatus.new(
      payload.fetch("repository").fetch("id"),
      payload.fetch("commit").fetch("sha"),
      payload.fetch("context"),
      payload.fetch("state"),
    )

    Audited::Audit.as_user(user) do
      if Changeling.config.pardot?
        # Avoid infinite loop where reporting our own status triggers this job
        # again and again.
        return if commit_status.context == GithubCommitStatus::COMPLIANCE_STATUS

        Multipass.where(release_id: commit_status.sha).each do |multipass|
          pull = RepositoryPullRequest.new(multipass)
          pull.synchronize
        end
      else
        CommitStatus.new(payload).update_multipass_testing
      end
    end
  end
end
