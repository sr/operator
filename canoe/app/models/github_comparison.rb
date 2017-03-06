class GithubComparison
  def initialize(repository, sha_a, sha_b)
    @repository = repository
    @sha_a = sha_a
    @sha_b = sha_b

    if !@sha_a
      raise ArgumentError, "sha_a can not be nil"
    end

    if !@sha_b
      raise ArgumentError, "sha_b can not be nil"
    end
  end

  def committers
    authors.collect { |author|
      author.try(:login) || author.try(:name)
    }.uniq.sort
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
    Octokit.compare(@repository, @sha_a, @sha_b).commits
  end
end
