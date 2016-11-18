namespace :monitor do
  desc "Monitor testing status for multipasses"
  task :testing => :environment do
    trap("TERM") { exit }
    begin
      MultipassMonitor.run
    rescue StandardError => e
      puts e
      exit 0
    end
  end
end
