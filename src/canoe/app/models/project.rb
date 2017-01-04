class Project < ApplicationRecord
  ARTIFACTORY_REPO = "pd-canoe".freeze

  has_many :deploy_notifications

  def self.enabled
    where.not(name: [ChefDelivery::PROJECT], id: TerraformProject.select(:project_id).all)
  end

  def status_contexts
    case name
    when "pardot"
      {
        "Test Jobs"                          => "PHP Tests",
        "WebDriver - Test Jobs"              => "WebDriver",
        "Salesforce Integration - Test Jobs" => "Salesforce Integration",
        "AB Combinatorial - Test Jobs"       => "AB Combinatorial",
        "List Combinatorial - Test Jobs"     => "List Combinatorial"
      }
    else
      {
        GithubRepository::COMPLIANCE_STATUS      => "Compliance",
        GithubCommitStatus::DEFAULT_TEST_CONTEXT => "Primary Build"
      }
    end
  end

  def titleized_name
    @friendly_name ||= name.titleize
  end

  def to_param
    name
  end

  def builds(branch:)
    aql = build_aql_query(branch: branch)
    artifact_hashes = Artifactory.client.post("/api/search/aql", aql, "Content-Type" => "text/plain")
      .fetch("results")

    artifact_hashes.map { |hash| Build.from_artifact_hash(self, hash) }
      .compact
      .sort_by { |deploy| -deploy.build_number }
  end

  def github_repository
    @github_repository ||= GithubRepository.new(Canoe.config.github_client, repository)
  end

  def commit_status(sha)
    github_repository.commit_status(sha)
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
    "#{Canoe.config.github_url}/#{repository}/releases/tag/#{tag.name}"
  end

  def branch_url(branch)
    "#{Canoe.config.github_url}/#{repository}/tree/#{branch.name}"
  end

  def commit_url(commit)
    "#{Canoe.config.github_url}/#{repository}/commits/#{commit.sha}"
  end

  def sha_url(sha)
    "#{Canoe.config.github_url}/#{repository}/commits/#{sha}"
  end

  def diff_url(deploy1, deploy2)
    return "#" unless deploy1 && deploy2
    "#{Canoe.config.github_url}/#{repository}/compare/#{deploy1.sha}...#{deploy2.sha}"
  end

  private

  def build_aql_query(branch:)
    conditions = [
      { "repo"       => { "$eq"    => ARTIFACTORY_REPO } },
      { "@gitRepo"   => { "$match" => "*/#{repository}.git" } },
    ]

    if branch.present?
      conditions << { "@gitBranch" => { "$eq" => branch } }
    end

    if bamboo_project
      conditions << { "@bambooProject" => { "$eq"    => bamboo_project } }
      conditions << { "@bambooPlan"    => { "$match" => "#{bamboo_plan}*" } } if bamboo_plan.present?

      if bamboo_job.present?
        conditions << { "@bambooJob" => { "$eq" => bamboo_job } }
      end
    end

    aql = %(items.find(#{JSON.dump("$and" => conditions)}))
    aql << %(.include("property.*"))
    aql << %(.sort({"$desc": ["created"]}))
    aql
  end
end
