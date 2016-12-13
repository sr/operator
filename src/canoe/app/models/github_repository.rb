class GithubRepository
  FAILURE = "failure".freeze
  PENDING = "pending".freeze
  SUCCESS = "success".freeze
  MASTER = "master".freeze
  EVEN = "even".freeze
  AHEAD = "ahead".freeze
  BEHIND = "behind".freeze

  # TODO(sr) Figure out some way to avoid hard-coding this, maybe
  COMPLIANCE_STATUS = "pardot/compliance".freeze

  def initialize(client, name)
    @client = client
    @name = name
  end

  def commit_status(sha)
    GithubCommitStatus.new(
      @client.combined_status(@name, sha),
      @client.compare(@name, MASTER, sha)
    )
  end
end
