class RepositoryOwnersFile < ApplicationRecord
  belongs_to :repository, class_name: "GithubRepository", foreign_key: "repository_id"

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
