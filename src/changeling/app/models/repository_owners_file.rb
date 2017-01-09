class RepositoryOwnersFile < ApplicationRecord
  def self.synchronize(repository_name)
    repository = Repository.find(repository_name)
    repository.synchronize_owners_files
    repository
  end
end
