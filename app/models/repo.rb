class Repo < ActiveRecord::Base
  ARTIFACTORY_REPO = "pd-canoe".freeze

  def full_name
    "Pardot/#{name}"
  end

  def to_param
    name
  end

  def deploys_via_artifacts?
    bamboo_project.present?
  end

  def builds(branch:)
    raise "no artifactory project configured" if bamboo_project.empty?

    artifacts = Artifactory::Resource::Artifact.property_search(
      bambooProject: bamboo_project,
      gitBranch:     branch,
      repos:         ARTIFACTORY_REPO,
    )

    artifacts.map { |artifact| ProvisionalDeploy.from_artifact_url(self, artifact.uri) }
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
end
