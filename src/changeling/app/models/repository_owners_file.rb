class RepositoryOwnersFile < ApplicationRecord
  belongs_to :repository, class_name: "GithubRepository", foreign_key: "repository_id"
end
