namespace :pardot do
  task :synchronize_repository_owners_files => :environment do
    [PardotRepository::BREAD, PardotRepository::CHEF].each do |repo_name|
      RepositoryOwnersFileSynchronizationJob.perform_later(repo_name)
    end
  end
end
