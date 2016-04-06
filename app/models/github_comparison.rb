class GithubComparison
  def initialize(repo_name, sha_a, sha_b)
    @repo_name = repo_name
    @sha_a = sha_a
    @sha_b = sha_b
  end

  def committers
    authors.collect do |author|
      author.try(:login) || author.try(:name)
    end.uniq.sort
  rescue Octokit::InternalServerError => e
    Instrumentation.log_exception(e, at: "DeployComparison", fn: "committers")
    []
  rescue Octokit::NotFound
    []
  end

  private

  def authors
    commits.collect do |commit|
      commit.author ||
      commit.committer ||
      commit.commit.author ||
      commit.commit.committer
    end
  end

  def commits
    if !@deploy_a && !@deploy_b
      return []
    end

    Octokit.compare(@repo_name, @sha_a, @sha_b).commits
  end
end
