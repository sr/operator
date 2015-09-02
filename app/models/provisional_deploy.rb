require "deployable"

class ProvisionalDeploy
  include Deployable

  attr_reader :artifact_url, :repo_name, :what, :what_details, :build_number, :sha

  def self.from_artifact_url(repo, artifact_url)
    artifact = Artifactory::Resource::Artifact.from_url(artifact_url)
    return nil unless artifact.properties["gitBranch"] && artifact.properties["buildNumber"] && artifact.properties["gitSha"]

    new(
      repo: repo,
      artifact_url: artifact_url,
      what: "branch",
      what_details: artifact.properties["gitBranch"].first,
      build_number: artifact.properties["buildNumber"].first.to_i,
      sha: artifact.properties["gitSha"].first,
    )
  end

  def self.from_tag(repo, tag)
    sha = nil
    begin
      ref = Octokit.ref(repo.full_name, "tags/#{tag}")
      tag_ref = Octokit.tag(repo.full_name, ref[:object][:sha])
      sha = tag_ref[:object][:sha]
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
    )
  end

  def initialize(repo:, artifact_url:, what:, what_details:, build_number:, sha:)
    @repo = repo
    @artifact_url = artifact_url
    @what = what
    @what_details = what_details
    @build_number = build_number
    @sha = sha
  end

  def repo_name
    @repo.name
  end

  def is_valid?
    sha.present?
  end
end
