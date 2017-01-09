class RepositoryOwnersFileSynchronizationJob < ActiveJob::Base
  queue_as :default

  def perform(repo_name)
    RepositoryOwnersFile.synchronize(repo_name)
  end
end
