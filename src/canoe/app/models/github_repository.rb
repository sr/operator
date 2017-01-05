class GithubRepository
  UNREPORTED = "unreported".freeze
  FAILURE = "failure".freeze
  PENDING = "pending".freeze
  SUCCESS = "success".freeze
  MASTER = "master".freeze
  IDENTICAL = "identical".freeze
  AHEAD = "ahead".freeze
  BEHIND = "behind".freeze

  # TODO(sr) Figure out some way to avoid hard-coding this, maybe
  COMPLIANCE_STATUS = "compliance".freeze

  def initialize(client, name)
    @client = client
    @name = name
  end

  def commit_status(sha)
    Instrumentation.log(fn: "commit_status", sha: sha) do
      GithubCommitStatus.new(
        @client.combined_status(@name, sha),
        @client.compare(@name, MASTER, sha)
      )
    end
  end
end
