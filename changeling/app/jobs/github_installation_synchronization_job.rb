class GithubInstallationSynchronizationJob < ActiveJob::Base
  queue_as :default

  def perform(installation_id)
    github_install = GithubInstallation.find(installation_id)
    github_install.synchronize
    github_install.repositories.each do |repo|
      RepositorySynchronizationJob.perform_later(repo.id)
    end
  end
end
