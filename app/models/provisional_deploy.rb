require "deployable"

class ProvisionalDeploy
  include Deployable

  attr_reader :artifact_url, :repo_name, :what, :what_details, :build_number, :sha, :passed_ci, :created_at

  def self.from_artifact_url(repo, artifact_url)
    hash = Artifactory.client.get(artifact_url, properties: nil)
    artifact = Artifactory::Resource::Artifact.from_hash(hash)

    return nil unless
      artifact.properties["gitBranch"] && \
      artifact.properties["buildNumber"] && \
      artifact.properties["gitSha"] && \
      artifact.properties["buildTimeStamp"]

    new(
      repo: repo,
      artifact_url: artifact_url,
      what: "branch",
      what_details: artifact.properties["gitBranch"].first,
      build_number: artifact.properties["buildNumber"].first.to_i,
      sha: artifact.properties["gitSha"].first,
      passed_ci: !!(artifact.properties["passedCI"] && artifact.properties["passedCI"].first == "true"),
      created_at: Time.parse(artifact.properties["buildTimeStamp"].first),
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
