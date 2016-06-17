class GithubRepository
  class Build
    def self.none
      new(url: nil, sha: nil, state: nil, updated_at: nil)
    end

    def initialize(attributes = {})
      @url = attributes.fetch(:url)
      @sha = attributes.fetch(:sha)
      @state = attributes.fetch(:state)
      @updated_at = attributes.fetch(:updated_at)
    end

    attr_reader :url, :sha, :state, :updated_at
  end

  class Fake
    attr_writer :current_build

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

    Build.new(
      url: status[:statuses].first[:target_url],
      sha: status[:sha],
      state: status[:state],
      updated_at: status[:statuses].first[:updated_at]
    )
  end
end
