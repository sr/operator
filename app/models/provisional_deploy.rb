require "deployable"
require "base64"
require "json"

class ProvisionalDeploy
  include Deployable

  attr_reader :artifact_url, :what, :what_details, :build_number, :sha, :passed_ci, :created_at
  attr_reader :options_validator, :options

  def self.from_artifact_url(repo, artifact_url)
    hash = Artifactory.client.get(artifact_url, properties: nil)
    artifact = Artifactory::Resource::Artifact.from_hash(hash)
    properties = artifact.properties.each_with_object({}) { |(k, v), h| h[k] = v.first }

    from_artifact_url_and_properties(repo, artifact_url, properties)
  end

  def self.from_artifact_hash(hash)
    artifact_url = Artifactory.client.build_uri(:get, "/" + ["api", "storage", hash["repo"], hash["path"], hash["name"]].join("/")).to_s
    properties = hash["properties"].each_with_object({}) { |p, h| h[p["key"]] = p["value"] }

    from_artifact_url_and_properties(hash["repo"], artifact_url, properties)
  end

  def self.from_artifact_url_and_properties(repo, artifact_url, properties)
    return nil unless
      properties["gitBranch"] && \
      properties["buildNumber"] && \
      properties["gitSha"] && \
      properties["buildTimeStamp"]

    options_validator = \
      begin
        properties["optionsValidator"] && JSON.parse(Base64.decode64(properties["optionsValidator"]))
      rescue JSON::ParseError
        Instrumentation.log_exception($!, "options-validator")
        nil
      end

    new(
      repo: repo,
      artifact_url: artifact_url,
      what: "branch",
      what_details: properties["gitBranch"],
      build_number: properties["buildNumber"].to_i,
      sha: properties["gitSha"],
      passed_ci: !!(properties["passedCI"] && properties["passedCI"] == "true"),
      created_at: Time.parse(properties["buildTimeStamp"]),
      options_validator: options_validator,
      options: {}
    )
  end

  def self.from_previous_deploy(repo, deploy)
    new(
      repo: repo,
      artifact_url: deploy.artifact_url,
      what: deploy.what,
      what_details: deploy.what_details,
      build_number: deploy.build_number,
      sha: deploy.sha,
      passed_ci: deploy.passed_ci,
      options_validator: deploy.options_validator,
      options: deploy.options
    )
  end

  def initialize(repo:, artifact_url:, what:, what_details:, build_number:, sha:, passed_ci:, created_at: nil, options_validator: nil, options: {})
    @repo = repo
    @artifact_url = artifact_url
    @what = what
    @what_details = what_details
    @build_number = build_number
    @sha = sha
    @passed_ci = passed_ci
    @created_at = created_at
    @options_validator = options_validator
    @options = options
  end

  def repo_name
    @repo.name
  end

  def is_valid?
    @sha.present?
  end

  def passed_ci?
    @passed_ci
  end
end
