class Project < ApplicationRecord
  ARTIFACTORY_REPO = "pd-canoe".freeze
  GITHUB_URL = "https://git.dev.pardot.com".freeze

  has_many :deploy_notifications

  def self.enabled
    where.not(name: [ChefDelivery::PROJECT], id: TerraformProject.select(:id).all)
  end

  def test_list
    case name
    when "pardot"
      {
        PPANT: "PPANT",
        WT: "WebDriver",
        TSIT: "Salesforce Integration",
        PPANTCLONE666: "AB Combinatorial",
        PPANTCLONE6666: "List Combinatorial"
      }
    else
      {}
    end
  end

  def titleized_name
    @friendly_name ||= name.titleize
  end

  def to_param
    name
  end

  def builds(branch:, include_untested_builds: false)
    aql = build_aql_query(branch: branch, include_untested_builds: include_untested_builds)
    artifact_hashes = Artifactory.client.post("/api/search/aql", aql, "Content-Type" => "text/plain")
      .fetch("results")

    artifact_hashes.map { |hash| Build.from_artifact_hash(hash) }
      .compact
      .sort_by { |deploy| -deploy.build_number }
  end

  def tags(count = 30)
    Octokit.tags(repository, per_page: count)
      .sort_by { |t| -t.name.sub(/\Abuild/, "").to_i }
  end

  def tag(name)
    ref = Octokit.ref(repository, "tags/#{name}")
    if ref
      Octokit.tag(repository, ref.object.sha)
    end
  end

  def latest_tag
    tags.first
  end

  def branches
    Octokit.auto_paginate = true
    Octokit.branches(repository)
  ensure
    Octokit.auto_paginate = false
  end

  def branch(branch)
    Octokit.branch(repository, branch)
  end

  # ----- PATHS ----

  def tag_url(tag)
    "#{GITHUB_URL}/#{repository}/releases/tag/#{tag.name}"
  end

  def branch_url(branch)
    "#{GITHUB_URL}/#{repository}/tree/#{branch.name}"
  end

  def commit_url(commit)
    "#{GITHUB_URL}/#{repository}/commits/#{commit.sha}"
  end

  def sha_url(sha)
    "#{GITHUB_URL}/#{repository}/commits/#{sha}"
  end

  def diff_url(deploy1, deploy2)
    return "#" unless deploy1 && deploy2
    "#{GITHUB_URL}/#{repository}/compare/#{deploy1.sha}...#{deploy2.sha}"
  end

  private

  def build_aql_query(branch:, include_untested_builds:)
    conditions = [
      { "repo"       => { "$eq"    => ARTIFACTORY_REPO } },
      { "@gitRepo"   => { "$match" => "*/#{repository}.git" } },
      { "@gitBranch" => { "$eq"    => branch } },
    ]

    if bamboo_project
      conditions << { "@bambooProject" => { "$eq"    => bamboo_project } }
      conditions << { "@bambooPlan"    => { "$match" => "#{bamboo_plan}*" } } if bamboo_plan.present?

      if bamboo_job.present?
        conditions << { "@bambooJob" => { "$eq" => bamboo_job } }
      end
    end

    if include_untested_builds
      # We can't know the difference between a failed build and a build that
      # hasn't yet completed CI. Since the intention is to be able to deploy
      # untested (but not failed) builds, our compromise is to display builds
      # only that have been created in the past hour.
      conditions << {
        "$or" => [
          { "@passedCI" => { "$eq" => "true" } },
          { "created"   => { "$gt" => 1.hour.ago.iso8601 } },
        ]
      }
    else
      conditions << { "@passedCI" => { "$eq" => "true" } }
    end

    aql = %(items.find(#{JSON.dump("$and" => conditions)}))
    aql << %(.include("property.*"))
    aql << %(.sort({"$desc": ["created"]}))
    aql
  end
end
