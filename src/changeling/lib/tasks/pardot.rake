namespace :pardot do
  desc "Synchronize repository OWNERS files"
  task :synchronize_repository_owners_files => :environment do
    Changeling.config.repository_owners_review_required.each do |repo_name|
      RepositoryOwnersFileSynchronizationJob.perform_later(repo_name)
    end
  end

  desc "Synchronize repositories from GitHub instances"
  task :synchronize => :environment do
    GithubInstallation.pluck(:id).each do |installation_id|
      GithubInstallationSynchronizationJob.perform_later(installation_id)
    end
  end
end
