# Worker for handling github commit statuses
class GitHubCommitStatusWorker < ActiveJob::Base
  def perform(id)
    multipass = Multipass.find(id)

    if multipass.rejected?
      multipass.failure_github_commit_status!
    elsif multipass.complete?
      multipass.approve_github_commit_status!
    else
      multipass.pending_github_commit_status!
    end

    begin
      multipass.update_github_comment
    # rubocop:disable Lint/RescueException
    rescue Exception
      Raven.capture_exception($!)
    end
  end
end
