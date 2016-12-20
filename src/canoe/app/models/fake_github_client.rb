class FakeGithubClient
  CombinedStatus = Struct.new(:status, :sha, :statuses) do
    def repository
      Struct.new(:full_name).new("Pardot/pardot")
    end
  end

  Status = Struct.new(:context, :state, :target_url)
  Comparison = Struct.new(:status, :ahead_by, :behind_by)

  def initialize(compare_state:, compliance_state:, tests_state: nil)
    @compare_state = compare_state || GithubRepository::IDENTICAL
    @compliance_state = compliance_state || GithubRepository::PENDING
    @tests_state = tests_state
  end

  attr_writer :compliance_state, :compare_state, :tests_state, :master_head_sha

  def combined_status(_repo, _sha)
    statuses = [
      Status.new(
        GithubRepository::COMPLIANCE_STATUS,
        @compliance_state,
        "https://changeling"
      )
    ]

    if @tests_state
      statuses << Status.new(
        GithubCommitStatus::TESTS_STATUS,
        @tests_state,
        "https://bamboo/1"
      )
    end

    CombinedStatus.new(
      @compliance_state,
      @master_head_sha || "sha1",
      statuses
    )
  end

  def compare(_repo, _branch, _sha)
    case @compare_state
    when GithubRepository::IDENTICAL
      Comparison.new(GithubRepository::IDENTICAL, 0, 0)
    when GithubRepository::BEHIND
      Comparison.new(GithubRepository::BEHIND, 0, 9)
    when GithubRepository::AHEAD
      Comparison.new(GithubRepository::AHEAD, 4, 0)
    else
      raise "invalid state: #{@compare_state.inspect}"
    end
  end
end
