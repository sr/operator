class GithubRepository
  FAILURE = "failure".freeze
  PENDING = "pending".freeze
  SUCCESS = "success".freeze
  MASTER = "master".freeze
  AHEAD = "ahead".freeze
  BEHIND = "behind".freeze

  class Build
    def self.none
      new(url: nil, branch: nil, sha: nil, state: nil, updated_at: nil)
    end

    def initialize(attributes = {})
      @url = attributes.fetch(:url)
      @sha = attributes.fetch(:sha)
      @branch = attributes.fetch(:branch)
      @state = attributes.fetch(:state)
      @updated_at = attributes.fetch(:updated_at)
      @compare_status = attributes.fetch(:compare_status, nil)
    end

    attr_reader :url, :branch, :sha, :state, :updated_at, :compare_status
  end

  class Fake
    attr_writer :current_build

    def initialize(build = nil)
      @current_build = build
    end

    def current_build(_branch)
      @current_build
    end
  end

  def initialize(client, name)
    @client = client
    @name = name
  end

  def current_build(branch)
    status = @client.combined_status(@name, branch)
    compare = @client.compare(@name, MASTER, branch)

    Build.new(
      url: status[:statuses].first[:target_url],
      sha: status[:sha],
      # TODO(sr) Remove hard-coded value once we move to Artifactory as our
      # source of build truth for Chef Delivery.
      branch: "master",
      state: status[:state],
      compare_status: compare[:status],
      updated_at: status[:statuses].first[:updated_at]
    )
  end
end
