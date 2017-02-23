class GithubCommitStatus
  # TODO(sr) Remove this and update callers to use the #compliance_url method
  # instead once we're ready to switch both Chef and Terraform to using the
  # compliance check
  DEFAULT_TEST_CONTEXT = "Test Jobs".freeze

  def self.none
    new(nil, nil)
  end

  def initialize(github_client, repository_name, commit_status)
    @github_client = github_client
    @repository_name = repository_name
    @commit_status = commit_status
  end

  def sha
    @commit_status.sha
  end

  def branch
    # TODO(sr) Remove hard-coded value once we move to Artifactory as our
    # source of build truth for Chef Delivery.
    GithubRepository::MASTER
  end

  def compare_state
    branch_compare.status
  end

  def tests_state
    state_for_context(DEFAULT_TEST_CONTEXT)
  end

  def tests_url
    url_for_context(DEFAULT_TEST_CONTEXT)
  end

  def compliance_state
    state_for_context(GithubRepository::COMPLIANCE_STATUS)
  end

  def compliance_description
    status = status_for_context(GithubRepository::COMPLIANCE_STATUS)
    if status
      status.description
    else
      ""
    end
  end

  def compliance_url
    url_for_context(GithubRepository::COMPLIANCE_STATUS)
  end

  def state_for_context(context)
    status = status_for_context(context)
    if status
      status.state
    else
      GithubRepository::UNREPORTED
    end
  end

  def url_for_context(context)
    status = status_for_context(context)
    if status
      status.target_url
    else
      ""
    end
  end

  private

  def branch_compare
    return @branch_compare if defined?(@branch_compare)
    @branch_compare = @github_client.compare(@repository_name, branch, sha)
  end

  def status_for_context(context)
    @commit_status.statuses.detect do |s|
      s.context == context
    end
  end
end
