class FakeGithubClient
  def initialize(compare_status:, compliance_status:, tests_status: nil)
    @compare_status = compare_status || GithubRepository::IDENTICAL
    @compliance_status = compliance_status || GithubRepository::PENDING
    @tests_status = tests_status
  end

  attr_writer :compliance_status, :compare_status, :tests_status, :master_head_sha

  def combined_status(_repo, _sha)
    statuses = [
      context: GithubRepository::COMPLIANCE_STATUS,
      state: @compliance_status,
      target_url: "https://changeling"
    ]

    if @tests_status
      statuses << {
        context: GithubCommitStatus::TESTS_STATUS,
        state: @tests_status,
        target_url: "https://bamboo/1"
      }
    end

    {
      status: @compliance_status,
      sha: @master_head_sha || "sha1",
      statuses: statuses
    }
  end

  def compare(_repo, _branch, _sha)
    case @compare_status
    when GithubRepository::IDENTICAL
      {
        ahead_by: 0,
        behind_by: 0,
        status: GithubRepository::IDENTICAL
      }
    when GithubRepository::BEHIND
      {
        ahead_by: 0,
        behind_by: 9,
        status: GithubRepository::BEHIND
      }
    when GithubRepository::AHEAD
      {
        ahead_by: 4,
        behind_by: 0,
        status: GithubRepository::AHEAD
      }
    else
      raise "invalid state: #{@compare_status.inspect}"
    end
  end
end
