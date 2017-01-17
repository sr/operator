class GithubRepository < ApplicationRecord
  self.table_name = "repositories"
  belongs_to :github_installation
end
