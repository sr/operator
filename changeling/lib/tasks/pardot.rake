namespace :pardot do
  desc "Synchronize repositories from GitHub instances"
  task :synchronize => :environment do
    GithubInstallation.pluck(:id).each do |installation_id|
      GithubInstallationSynchronizationJob.perform_later(installation_id)
    end
  end
end
