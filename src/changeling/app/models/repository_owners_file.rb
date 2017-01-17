class RepositoryOwnersFile < ApplicationRecord
  belongs_to :repository, class_name: "GithubRepository", foreign_key: "repository_id"

  def self.synchronize(repository_name)
    repository = Repository.find(repository_name)
    repository.synchronize_owners_files
    repository
  end
end
