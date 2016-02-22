module ReplicationFixing
  class FixingStatusClient
    SHARD_NAMESPACE = "fixing_status"

    # Status keys expire after 10 minutes. The assumption is that if we haven't
    # touched the key in 10 minutes, the errors have subsided. In the future,
    # it'd be nice to be sure of this assumption (e.g., by having rep_fix report
    # success).
    KEY_TTL = 60 * 10

    Status = Struct.new(:fixing?, :started_at)

    def initialize(redis)
      @redis = redis
    end

    # Ensures that we have taken note of the fixing that's going on. Creates a
    # status if one doesn't exist, or does nothing if one already does.
    def ensure_fixing_status_ongoing(shard:)
      key = [SHARD_NAMESPACE, shard.prefix, shard.shard_id].join(":")
      @redis.multi do
        @redis.hsetnx(key, "started_at", Time.now.to_i)
        @redis.expire(key, KEY_TTL)
      end
    end

    # Deletes the status entry. Used when the fix is no longer active.
    def reset_status(shard:)
      @redis.del([SHARD_NAMESPACE, shard.prefix, shard.shard_id].join(":"))
    end

    def status(shard:)
      hash = @redis.hgetall([SHARD_NAMESPACE, shard.prefix, shard.shard_id].join(":"))

      if hash.empty?
        Status.new(false, nil)
      else
        Status.new(true, Time.at(hash.fetch("started_at", "0").to_i))
      end
    end
  end
end
