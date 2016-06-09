class GithubRepository
  class Error < StandardError; end

  class Build
    def self.none
      new(url: nil, sha: nil, state: nil)
    end

    def initialize(attributes={})
      @url = attributes.fetch(:url)
      @sha = attributes.fetch(:sha)
      @state = attributes.fetch(:state)
    end

    attr_reader :url, :sha, :state
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

  PENDING = "pending".freeze

  def initialize(client, name)
    @client = client
    @name = name
  end

  def current_build(branch)
    status = @client.combined_status(@name, branch)

    Build.new(
      url: status[:statuses].first[:target_url],
      sha: status[:sha],
      state: status[:state]
    )
  end

  def current_deploy(environment, branch, deploy_task)
    options = {
      environment: environment,
      ref: branch,
      task: deploy_task,
    }
    deploys = @client.deployments(@name, options)

    if deploys.empty?
      return Deploy.none
    end

    deploy = deploys[0]
    branch = deploy[:payload].fetch(:branch, "master")
    statuses = @client.list_deployment_statuses(deploy[:url])

    if statuses.empty?
      return Deploy.new(
        url: deploy[:url],
        environment: deploy[:environment],
        branch: branch,
        sha: deploy[:sha],
        state: PENDING
      )
    end

    status = statuses[0]
    Deploy.new(
      url: deploy[:url],
      environment: deploy[:environment],
      branch: branch,
      sha: deploy[:sha],
      state: status[:state]
    )
  end

  Response = Struct.new(:success?, :deploy)

  def create_pending_deploy(environment, task, build, branch)
    options = {
      auto_merge: false,
      environment: environment,
      payload: JSON.dump(branch: branch),
      required_contexts: [], # TODO(sr) Array(build.context),
      task: task,
    }

    deploy = @client.create_deployment(@name, build.sha, options)
    if deploy[:url].blank?
      raise Error, "unable to create deploy: #{deploy.inspect}"
    end

    status = @client.create_deployment_status(deploy[:url], PENDING)
    if status[:url].blank?
      raise Error, "unable to create deploy status: #{status.inspect}"
    end

    Response.new(
      true,
      Deploy.new(
        url: deploy[:url],
        environment: deploy[:environment],
        branch: branch,
        sha: deploy[:ref],
        state: status[:state]
      )
    )
  end

  CompleteResponse = Struct.new(:success?, :error)

  def complete_deploy(deploy_url, status)
    status = @client.create_deployment_status(deploy_url, status)

    if status[:url].blank?
      return CompleteResponse.new(false, status[:message])
    end

    CompleteResponse.new(true, nil)
  end
end
