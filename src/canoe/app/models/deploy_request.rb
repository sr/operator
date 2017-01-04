class DeployRequest
  class Response
    def self.error(message)
      new(nil, message)
    end

    def self.success(deploy)
      new(deploy, nil)
    end

    def initialize(deploy, error)
      @deploy = deploy
      @error = error
    end

    attr_reader :error, :deploy

    def error?
      !!@error
    end

    def as_proto_json
      proto = Canoe::CreateDeployResponse.new(
        error: error?,
        message: error || "",
        deploy_id: @deploy&.id || 0
      )
      proto.as_json
    end

    def to_json(_)
      JSON.dump(error: error?, message: error, deploy: @deploy&.attributes)
    end
  end

  # rubocop:disable Metrics/ParameterLists
  def initialize(project, target, user, artifact_url, lock, server_hostnames, options)
    @project = project
    @target = target
    @user = user
    @artifact_url = artifact_url
    @lock = lock
    @server_hostnames = server_hostnames
    @options = options
  end

  def handle
    if !@project
      return Response.error("No project specified")
    end

    if !@target
      return Response.error("No target specified")
    end

    if !@target.user_can_deploy?(@project, @user)
      return Response.error("User #{@user} is not authorized to deploy #{@project.name}")
    end

    if !@target.active_deploy(@project).nil?
      return Response.error("There is already an active deploy for #{project.name}")
    end

    if !build
      return Response.error("No build specified")
    end

    if !build.valid?
      return Response.error("Build is not valid")
    end

    if !compliance_allows_deploy?
      return Response.error("The build is does not meet compliance requirements: #{build.compliance_description}")
    end

    deploy = @target.transaction do
      if @server_hostnames && !@server_hostnames.empty?
        servers = @target.servers(project: @project).where(hostname: @server_hostnames)
      elsif @project.all_servers_default
        servers = @target.servers(project: @project)
      else
        servers = []
      end

      new_deploy = @target.deploys.create!(
        auth_user: @user,
        project_name: @project.name,
        branch: @build.branch,
        completed: false,
        sha: @build.sha,
        compliance_state: @build.compliance_state,
        tests_state: @build.tests_state,
        build_number: @build.build_number,
        artifact_url: @build.artifact_url,
        options_validator: @build.options_validator,
        options: @options,
      )
      DeployWorkflow.initiate(
        deploy: new_deploy,
        servers: servers,
        maximum_unavailable_percentage_per_datacenter: @project.maximum_unavailable_percentage_per_datacenter,
      )
      new_deploy
    end

    @target.lock!(@project, @user) if @lock

    Response.success(deploy)
  end

  private

  def build
    @build ||= Build.from_artifact_url(@project, @artifact_url)
  end

  def compliance_allows_deploy?
    # Allows deploys from default branch in emergencies. Something could not
    # have gotten into the default branch unless it passed compliance earlier or
    # an emergency override was used.
    if !@project.compliant_builds_required? || @project.default_branch == build.branch
      true
    else
      build.compliant?
    end
  end
end
