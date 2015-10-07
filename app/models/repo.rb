class Repo < ActiveRecord::Base
  ARTIFACTORY_REPO = "pd-canoe".freeze
  GITHUB_URL = "https://git.dev.pardot.com".freeze

  def full_name
    "Pardot/#{name}"
  end

  def to_param
    name
  end

  def builds(branch:, include_untested_builds: false, limit: nil)
    aql = build_aql_query(branch: branch, include_untested_builds: include_untested_builds, limit: limit)
    artifact_urls = Artifactory.client.post("/api/search/aql", aql, "Content-Type" => "text/plain")
      .fetch("results")
      .map { |hash| build_artifact_url_from_hash(hash) }

    # Rails development environment is not thread-safe, but in production we can
    # run multiple requests to Artifactory concurrently and achieve a
    # significant speedup in wall clock time.
    threads = Rails.env.development? ? 1 : 10

    Parallel.map(artifact_urls, in_threads: threads) { |url| ProvisionalDeploy.from_artifact_url(self, url) }
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

  private
  def build_aql_query(branch:, include_untested_builds:, limit:)
    conditions = [
      {"repo"       => {"$eq"    => ARTIFACTORY_REPO}},
      {"@gitRepo"   => {"$match" => "*/#{full_name}.git"}},
      {"@gitBranch" => {"$eq"    => branch}},
    ]

    if bamboo_project
      conditions << {"@bambooProject" => {"$eq"    => bamboo_project}}
      conditions << {"@bambooPlan"    => {"$match" => "#{bamboo_plan}*"}} if bamboo_plan.present?
    end

    if include_untested_builds
      # We can't know the difference between a failed build and a build that
      # hasn't yet completed CI. Since the intention is to be able to deploy
      # untested (but not failed) builds, our compromise is to display builds
      # only that have been created in the past hour.
      conditions << {
        "$or" => [
          {"@passedCI" => {"$eq" => "true"}},
          {"created"   => {"$gt" => 1.hour.ago.iso8601}},
        ]
      }
    else
      conditions << {"@passedCI" => {"$eq" => "true"}}
    end

    aql = %(items.find(#{JSON.dump("$and" => conditions)}))
    aql << %(.sort({"$desc": ["created"]}))
    aql << %(.limit(#{limit.to_i})) if limit
    aql
  end

  def build_artifact_url_from_hash(hash)
    Artifactory.client.build_uri(:get, "/" + ["api", "storage", hash["repo"], hash["path"], hash["name"]].join("/")).to_s
  end
end
