class GithubRepository
  FAILURE = "failure".freeze
  PENDING = "pending".freeze
  SUCCESS = "success".freeze
  MASTER = "master".freeze
  AHEAD = "ahead".freeze
  BEHIND = "behind".freeze
  # TODO(sr) Figure out some way to avoid hard-coding this, maybe
  COMPLIANCE_STATUS = "pardot/compliance".freeze

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
      @compliance = attributes.fetch(:compliance, {})
    end

    attr_reader :url, :branch, :sha, :state, :updated_at, :compare_status, :compliance

    def compliance_state
      if @compliance
        @compliance.fetch(:state)
      else
        PENDING
      end
    end

    def compliance_url
      if @compliance
        @compliance.fetch(:target_url)
      end
    end
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
    compliance = satus[:statuses].detect { |s| s[:context] == COMPLIANCE_STATUS }

    Build.new(
      url: status[:statuses].first[:target_url],
      sha: status[:sha],
      # TODO(sr) Remove hard-coded value once we move to Artifactory as our
      # source of build truth for Chef Delivery.
      branch: "master",
      state: status[:state],
      compliance: compliance,
      compare_status: compare[:status],
      updated_at: status[:statuses].first[:updated_at]
    )
  end
end
