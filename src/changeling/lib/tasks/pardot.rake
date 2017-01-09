namespace :pardot do
  desc "Synchronize repository OWNERS files"
  task :synchronize_repository_owners_files => :environment do
    Changeling.config.repository_owners_review_required.each do |repo_name|
      RepositoryOwnersFileSynchronizationJob.perform_later(repo_name)
    end
  end
end
