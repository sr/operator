# GitHub Status related methods for multipasses.
module Multipass::GitHubStatuses
  def commit_status_options
    {
      context: Changeling.config.compliance_status_context,
      target_url: permalink,
      description: compliance_status.github_commit_status_description
    }
  end

  def github_login_for_requester
    login = Employee.by_heroku_email(requester)
    login ? login.github : nil
  end

  def commit_status_creator
    if Changeling.config.pardot?
      return User.ghost
    end

    creator = if rejected?
                User.find_by(github_login: rejector)
              elsif emergency_approver.present?
                User.find_by(github_login: emergency_approver)
              elsif complete?
                User.find_by(github_login: peer_reviewer)
              else
                User.find_by(github_login: github_login_for_requester)
              end
    creator || User.ghost
  end

  def github_client
    @github_client = Clients::GitHub.new(commit_status_creator.github_token)
  end

  def callback_to_github
    if repository.update_github_commit_status?
      GitHubCommitStatusWorker.perform_later(id)
    end
  end

  def approve_github_commit_status!
    return unless repository && repository.participating?
    github_client.create_success_commit_status(repository.name_with_owner, release_id, commit_status_options)
  end

  def pending_github_commit_status!
    return unless repository && repository.participating?
    github_client.create_pending_commit_status(repository.name_with_owner, release_id, commit_status_options)
  end

  def failure_github_commit_status!
    return unless repository && repository.participating?
    github_client.create_failure_commit_status(repository.name_with_owner, release_id, commit_status_options)
  end

  def check_commit_statuses!
    return unless repository && repository.participating?

    status = find_testing_status

    return unless status
    self.testing = true
  end

  def find_testing_status
    statuses = github_client.commit_statuses(repository.name_with_owner, release_id)

    statuses.detect do |s|
      cs = CommitStatus.new(s)
      cs.testing_success? && cs.valid_context?
    end
  end
end
