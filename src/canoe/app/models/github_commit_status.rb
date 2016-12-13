class GithubCommitStatus
  # TODO(sr) Figure out some way to avoid hard-coding this, maybe
  COMPLIANCE_STATUS = "pardot/compliance".freeze

  def self.none
    new(nil, nil)
  end

  def initialize(commit_status, branch_compare)
    @commit_status = commit_status
    @branch_compare = branch_compare
  end

  def sha
    @commit_status.sha
  end

  def branch
    # TODO(sr) Remove hard-coded value once we move to Artifactory as our
    # source of build truth for Chef Delivery.
    GithubRepository::MASTER
  end

  def compare_status
    @branch_compare.status
  end

  def tests_state
    if tests_status
      tests_status.state
    else
      GithubRepository::PENDING
    end
  end

  def compliance_state
    if compliance_status
      compliance_status.state
    else
      GithubRepository::PENDING
    end
  end

  def tests_url
    if tests_status
      tests_status.target_url
    else
      ""
    end
  end

  def compliance_url
    if compliance_status
      compliance_status.target_url
    else
      ""
    end
  end

  private

  def compliance_status
    @commit_status.statuses.detect do |s|
      s.context == GithubRepository::COMPLIANCE_STATUS
    end
  end

  # TODO(sr) Remove this and update callers to use the #compliance_url method
  # instead once we're ready to switch both Chef and Terraform to using the
  # pardot/compliance check
  TESTS_STATUS = "Test Jobs".freeze

  def tests_status
    @commit_status.statuses.detect do |s|
      s.context == TESTS_STATUS
    end
  end
end
