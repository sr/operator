namespace :db do
  desc "Update complete flag in database for multipasses"
  task :update_complete => :environment do
    Multipass.find_each do |m|
      m.update_column(:complete, m.complete?)
    end
  end
end
