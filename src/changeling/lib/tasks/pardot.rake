namespace :pardot do
  task :synchronize_owners do
    [PardotRepository::BREAD, PardotRepository::CHEF].each do |repo_name|
      RepositoryOwnersFile.synchronize(repo_name)
    end
  end
end
