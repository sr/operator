class GithubInstallationSynchronizationJob < ActiveJob::Base
  queue_as :default

  def perform(installation_id)
    GithubInstallation.find(installation_id).synchronize
  end
end
