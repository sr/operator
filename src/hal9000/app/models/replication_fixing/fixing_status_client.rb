require "replication_fixing/shard"

module ReplicationFixing
  class FixingStatusClient
    SHARD_NAMESPACE = "fixing_status".freeze

    # Status keys expire after 10 minutes. The assumption is that if we haven't
    # touched the key in 10 minutes, the errors have subsided. In the future,
    # it'd be nice to be sure of this assumption (e.g., by having rep_fix report
    # success).
    KEY_TTL = 60 * 10

    Status = Struct.new(:fixing?, :shard, :started_at)

    def initialize(datacenter, redis)
      @datacenter = datacenter
      @redis = redis
    end

    # Ensures that we have taken note of the fixing that's going on. Creates a
    # status if one doesn't exist, or does nothing if one already does.
    def set_active(shard:, active:)
      key = [SHARD_NAMESPACE, @datacenter, shard.prefix, shard.shard_id].join(":")
      @redis.multi do
        @redis.hsetnx(key, "started_at", Time.now.to_i)
        @redis.hset(key, "active", active)
        @redis.expire(key, KEY_TTL)
      end
    end

    # Deletes the status entry. Used when the fix is no longer active.
    def reset(shard:)
      @redis.del([SHARD_NAMESPACE, @datacenter, shard.prefix, shard.shard_id].join(":"))
    end

    def status(shard:)
      hash = @redis.hgetall([SHARD_NAMESPACE, @datacenter, shard.prefix, shard.shard_id].join(":"))

      if hash.empty?
        Status.new(false, shard, nil)
      else
        Status.new(
          (hash.fetch("active", "false") == "true"),
          shard,
          Time.at(hash.fetch("started_at", "0").to_i)
        )
      end
    end

    def current_fixes
      @redis.keys([SHARD_NAMESPACE, @datacenter, "*"].join(":")).sort.map { |key|
        _, datacenter, prefix, shard_id = key.split(":")

        shard = Shard.new(prefix, shard_id.to_i, datacenter)
        status(shard: shard)
      }.select(&:fixing?)
    end
  end
end
