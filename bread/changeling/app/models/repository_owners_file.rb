class RepositoryOwnersFile < ApplicationRecord
  belongs_to :repository, class_name: "GithubRepository", foreign_key: "repository_id"

  attr_reader :parsed

  def parse
    @parsed = OwnersFile.new(content)
    self
  end

  def url
    [
      Changeling.config.github_url,
      repository.full_name,
      "blob",
      "master",
      path_name
    ].join("/")
  end
end
