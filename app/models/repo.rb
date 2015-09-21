class Repo < ActiveRecord::Base
  ARTIFACTORY_REPO = "pd-canoe".freeze
  GITHUB_URL = "https://git.dev.pardot.com".freeze

  def full_name
    "Pardot/#{name}"
  end

  def to_param
    name
  end

  def builds(branch:)
    # should never happen, but a sanity check in case this code path is encountered
    raise "repo does not deploy via artifacts" unless deploys_via_artifacts?

    artifacts = Artifactory::Resource::Artifact.property_search(
      gitRepo:       "*/#{full_name}.git",
      gitBranch:     branch,
      repos:         ARTIFACTORY_REPO,
    )

    # Rails development environment is not thread-safe, but in production we can
    # run multiple requests to Artifactory concurrently and achieve a
    # significant speedup in wall clock time.
    threads = Rails.env.development? ? 1 : 10

    Parallel.map(artifacts, in_threads: threads) { |artifact| ProvisionalDeploy.from_artifact_url(self, artifact.uri) }
      .compact
      .sort_by { |deploy| -deploy.build_number }
  end

  def tags(count = 30)
    Octokit.tags(full_name, per_page: count)
      .sort_by { |t| -t.name.sub(/\Abuild/, "").to_i }
  end

  def tag(name)
    ref = Octokit.ref(full_name, "tags/#{name}")
    if ref
      Octokit.tag(full_name, ref.object.sha)
    else
      nil
    end
  end

  def latest_tag
    tags.first
  end

  def branches
    Octokit.auto_paginate = true
    Octokit.branches(full_name)
  ensure
    Octokit.auto_paginate = false
  end

  def branch(branch)
    Octokit.branch(full_name, branch)
  end

  # ----- PATHS ----

  def tag_url(tag)
    "#{GITHUB_URL}/#{full_name}/releases/tag/#{tag.name}"
  end
  
  def branch_url(branch)
    "#{GITHUB_URL}/#{full_name}/tree/#{branch.name}"
  end
  
  def commit_url(commit)
    "#{GITHUB_URL}/#{full_name}/commits/#{commit.sha}"
  end
  
  def sha_url(sha)
    "#{GITHUB_URL}/#{full_name}/commits/#{sha}"
  end
  
  def diff_url(deploy1, deploy2)
    return "#" unless deploy1 && deploy2
    "#{GITHUB_URL}/#{full_name}/compare/#{deploy1.sha}...#{deploy2.sha}"
  end
end
