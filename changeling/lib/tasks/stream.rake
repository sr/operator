namespace :stream do
  desc "Process stream events"
  task :process => :environment do
    trap("TERM") { exit }
    Stream::Processor.run
  end

  desc "Clean checkpoints"
  task :clean => :environment do
    redis = Redis.new(url: ENV["REDIS_URL"])
    shards = redis.hkeys("kinesis_states-shards") || []
    shards.each do |s|
      redis.del "kinesis_states-#{s}"
    end
    redis.del "kinesis_states-shards"
  end
end
