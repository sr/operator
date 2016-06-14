class GithubRepository
  class Error < StandardError; end

  class Build
    def self.none
      new(url: nil, sha: nil, state: nil, updated_at: nil)
    end

    def initialize(attributes={})
      @url = attributes.fetch(:url)
      @sha = attributes.fetch(:sha)
      @state = attributes.fetch(:state)
      @updated_at = attributes.fetch(:updated_at)
    end

    attr_reader :url, :sha, :state, :updated_at
  end

  class Deploy
    def self.none
      new(url: nil, environment: nil, branch: nil, sha: nil, state: nil)
    end

    def initialize(attributes={})
      @url = attributes.fetch(:url)
      @environment = attributes.fetch(:environment)
      @branch = attributes.fetch(:branch)
      @sha = attributes.fetch(:sha)
      @state = attributes.fetch(:state)
    end

    attr_reader :url, :environment, :branch, :sha, :state

    def to_json(_)
      JSON.dump(
        url: @url,
        environment: @environment,
        branch: @branch,
        sha: @sha,
        state: @state
      )
    end
  end

  def initialize(client, name)
    @client = client
    @name = name
  end

  def current_build(branch)
    status = @client.combined_status(@name, branch)

    Build.new(
      url: status[:statuses].first[:target_url],
      sha: status[:sha],
      state: status[:state],
      updated_at: status[:statuses].first[:updated_at]
    )
  end

  Response = Struct.new(:success?, :deploy)
end
