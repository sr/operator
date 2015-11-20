require "deployable"

class ProvisionalDeploy
  include Deployable

  attr_reader :artifact_url, :what, :what_details, :build_number, :sha, :passed_ci, :created_at

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

    new(
      repo: repo,
      artifact_url: artifact_url,
      what: "branch",
      what_details: properties["gitBranch"],
      build_number: properties["buildNumber"].to_i,
      sha: properties["gitSha"],
      passed_ci: !!(properties["passedCI"] && properties["passedCI"] == "true"),
      created_at: Time.parse(properties["buildTimeStamp"]),
    )
  end

  def self.from_tag(repo, tag)
    sha = nil
    begin
      ref = Octokit.ref(repo.full_name, "tags/#{tag}")
      tag_ref = Octokit.tag(repo.full_name, ref[:object][:sha])
      sha = tag_ref[:object][:sha]
      created_at = tag_ref[:tagger][:date]
    rescue Octokit::NotFound
      sha = nil
    end

    new(
      repo: repo,
      artifact_url: nil,
      what: "tag",
      what_details: tag,
      build_number: tag.sub(/\Abuild/, "").to_i,
      sha: sha,
      passed_ci: true,
      created_at: created_at,
    )
  end

  def self.from_branch(repo, branch)
    sha = nil
    begin
      ref = Octokit.ref(repo.full_name, "heads/#{branch}")
      sha = ref[:object][:sha]
    rescue Octokit::NotFound
      sha = nil
    end

    new(
      repo: repo,
      artifact_url: nil,
      what: "branch",
      what_details: branch,
      build_number: nil,
      sha: sha,
      passed_ci: true,
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
    )
  end

  def initialize(repo:, artifact_url:, what:, what_details:, build_number:, sha:, passed_ci:, created_at: nil)
    @repo = repo
    @artifact_url = artifact_url
    @what = what
    @what_details = what_details
    @build_number = build_number
    @sha = sha
    @passed_ci = passed_ci
    @created_at = created_at
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
