module ReplicationFixing
  class FixingStatusClient
    SHARD_NAMESPACE = "fixing_status"

    Status = Struct.new(:fixing?, :started_at)

    def initialize(redis)
      @redis = redis
    end

    # Ensures that we have taken note of the fixing that's going on. Creates a
    # status if one doesn't exist, or does nothing if one already does.
    def ensure_fixing_status_ongoing(shard_id)
      @redis.hsetnx([SHARD_NAMESPACE, shard_id].join(":"), "started_at", Time.now.to_i)
    end

    def status(shard_id)
      hash = @redis.hgetall([SHARD_NAMESPACE, shard_id].join(":"))

      if hash.empty?
        Status.new(false, nil)
      else
        Status.new(true, Time.at(hash.fetch("started_at", "0").to_i))
      end
    end
  end
end
