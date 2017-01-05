require "base64"
require "json"

class Build
  attr_reader :artifact_url, :branch, :build_number, :sha, :created_at, :properties
  attr_reader :options_validator, :options

  def self.from_artifact_url(project, artifact_url)
    hash = Artifactory.client.get(artifact_url, properties: nil)
    artifact = Artifactory::Resource::Artifact.from_hash(hash)
    properties = artifact.properties.each_with_object({}) { |(k, v), h| h[k] = v.first }

    from_artifact_url_and_properties(project, artifact_url, properties)
  end

  def self.from_artifact_hash(project, hash)
    artifact_url = Artifactory.client.build_uri(:get, "/" + ["api", "storage", hash["repo"], hash["path"], hash["name"]].join("/")).to_s
    properties = hash["properties"].each_with_object({}) { |p, h| h[p["key"]] = p["value"] }

    from_artifact_url_and_properties(project, artifact_url, properties)
  end

  def self.from_artifact_url_and_properties(project, artifact_url, properties)
    return nil unless
      properties["gitBranch"] && \
      properties["buildNumber"] && \
      properties["gitSha"] && \
      properties["buildTimeStamp"]

    options_validator = \
      begin
        properties["optionsValidator"] && JSON.parse(Base64.decode64(properties["optionsValidator"]))
      rescue JSON::ParseError
        Instrumentation.log_exception($!,
          at: "Build",
          fn: "from_artifact_url_and_properties"
        )
        nil
      end

    new(
      project: project,
      artifact_url: artifact_url,
      branch: properties["gitBranch"],
      build_number: properties["buildNumber"].to_i,
      sha: properties["gitSha"],
      created_at: Time.parse(properties["buildTimeStamp"]).iso8601,
      options_validator: options_validator,
      options: {},
      properties: properties
    )
  end

  def self.from_previous_deploy(project, deploy)
    build = from_artifact_url(project, deploy.artifact_url)
    build.options = deploy.options
    build
  end

  def self.load_commit_statuses(builds)
    threads = \
      builds.map { |b|
        Thread.new(b) do |build|
          build.load_commit_status
        end
      }
    threads.each(&:join)
  end

  def initialize(project:, artifact_url:, branch:, build_number:, sha:, created_at: nil, options_validator: nil, options: {}, properties: {})
    @project = project
    @artifact_url = artifact_url
    @branch = branch
    @build_number = build_number
    @sha = sha
    @created_at = created_at
    @options_validator = options_validator
    @options = options
    @properties = properties
  end

  def project_name
    @project.name
  end

  def build_id
    @properties["buildID"]
  end

  def repo_url
    @properties["gitRepo"].gsub(/\.git$/, "")
  end

  def url
    @properties["buildResults"]
  end

  def show_single_servers?
    !@project.all_servers_default
  end

  def valid?
    @sha.present?
  end

  def commit_status
    @commit_status ||= @project.commit_status(@sha)
  end

  def load_commit_status
    commit_status
    true
  end

  def compliant?
    compliance_state == GithubRepository::SUCCESS
  end

  def compliance_allows_deploy?
    # Allows deploys from default branch in emergencies. Something could not
    # have gotten into the default branch unless it passed compliance earlier or
    # an emergency override was used.
    if !@project.compliant_builds_required? || @project.default_branch == branch
      true
    else
      compliant?
    end
  end

  def compliance_state
    commit_status.compliance_state
  end

  def compliance_description
    commit_status.compliance_description
  end

  # The build artifact--not the commit status--remains the source of truth for
  # whether a build has passed CI because it is very possible for multiple
  # builds to reference the same SHA yet have differing results.

  # For instance, a build that is a child build of another build on which it
  # depends might pull in a different version of the dependency each time it
  # builds, even though the underlying SHA is the same. This could produce
  # dramatically different deployment results, even if the SHA for the build is
  # the same. For this reason we cannot use the test status associated with
  # `commit_status` to determine if a given _artifact_ has passed CI.
  def passed_ci?
    # TODO(alindeman) passedCI should be a tristate: pending, success, failed
    @properties["passedCI"] == "true"
  end

  def state_for_context(context)
    commit_status.state_for_context(context)
  end

  def url_for_context(context)
    commit_status.url_for_context(context)
  end
end
