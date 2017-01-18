class RepositorySynchronizationJob < ActiveJob::Base
  queue_as :default

  def perform(repository_id)
    GithubRepository.find(repository_id).synchronize
  end
end
