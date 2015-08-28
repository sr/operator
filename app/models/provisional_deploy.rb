require "deployable"

class ProvisionalDeploy
  include Deployable

  attr_reader :artifact_url, :repo_name, :what, :what_details, :build_number, :sha

  def self.from_artifact_url(repo, artifact_url)
    artifact = Artifactory::Resource::Artifact.from_url(artifact_url)
    new(
      repo: repo,
      artifact_url: artifact_url,
      what: "branch",
      what_details: artifact.properties["branch"].first,
      build_number: Integer(artifact.properties["build"].first),
      sha: artifact.properties["sha"].first,
    )
  end

  def self.from_tag(repo, tag)
    ref = Octokit.ref(repo.full_name, "tags/#{tag}")
    new(
      repo: repo,
      artifact_url: nil,
      what: "tag",
      what_details: tag,
      build_number: Integer(tag.sub(/\Abuild/, "")),
      sha: ref[:object][:sha],
    )
  end

  def self.from_branch(repo, branch)
    ref = Octokit.ref(repo.full_name, "heads/#{branch}")
    new(
      repo: repo,
      artifact_url: nil,
      what: "branch",
      what_details: branch,
      build_number: nil,
      sha: ref[:object][:sha],
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
