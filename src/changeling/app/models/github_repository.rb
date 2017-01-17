class GithubRepository < ApplicationRecord
  self.table_name = "repositories"

  belongs_to :github_installation
  has_many :repository_owners_files, foreign_key: "repository_id"
  has_many :repository_commit_statuses, foreign_key: "repository_id"
end
