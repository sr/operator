class FakeGithubClient
  CombinedStatus = Struct.new(:status, :sha, :statuses)
  Status = Struct.new(:context, :state, :target_url)
  Comparison = Struct.new(:status, :ahead_by, :behind_by)

  def initialize(compare_status:, compliance_status:, tests_status: nil)
    @compare_status = compare_status || GithubRepository::IDENTICAL
    @compliance_status = compliance_status || GithubRepository::PENDING
    @tests_status = tests_status
  end

  attr_writer :compliance_status, :compare_status, :tests_status, :master_head_sha

  def combined_status(_repo, _sha)
    statuses = [
      Status.new(
        GithubRepository::COMPLIANCE_STATUS,
        @compliance_status,
        "https://changeling"
      )
    ]

    if @tests_status
      statuses << Status.new(
        GithubCommitStatus::TESTS_STATUS,
        @tests_status,
        "https://bamboo/1"
      )
    end

    CombinedStatus.new(
      @compliance_status,
      @master_head_sha || "sha1",
      statuses
    )
  end

  def compare(_repo, _branch, _sha)
    case @compare_status
    when GithubRepository::IDENTICAL
      Comparison.new(GithubRepository::IDENTICAL, 0, 0)
    when GithubRepository::BEHIND
      Comparison.new(GithubRepository::BEHIND, 0, 9)
    when GithubRepository::AHEAD
      Comparison.new(GithubRepository::AHEAD, 4, 0)
    else
      raise "invalid state: #{@compare_status.inspect}"
    end
  end
end
