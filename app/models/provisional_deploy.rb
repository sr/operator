require "deployable"

class ProvisionalDeploy
  include Deployable

  include Artifactory::Resource

  attr_reader :artifact_url, :repo_name, :what, :what_details, :sha

  def self.from_artifact_url(repo, artifact_url)
    # TODO: Artifactory
    raise "Not implemented"
  end

  def self.from_tag(repo, tag)
    ref = Octokit.ref(repo.full_name, "tags/#{tag}")
    new(
      repo: repo,
      artifact_url: nil,
      what: "tag",
      what_details: tag,
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
      sha: ref[:object][:sha],
    )
  end

  def initialize(repo:, artifact_url:, what:, what_details:, sha:)
    @repo = repo
    @artifact_url = artifact_url
    @what = what
    @what_details = what_details
    @sha = sha
  end

  def repo_name
    @repo.name
  end

  def is_valid?
    sha.present?
  end
end
