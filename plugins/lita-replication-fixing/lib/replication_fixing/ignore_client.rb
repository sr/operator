module ReplicationFixing
  class IgnoreClient
    IGNORE_ALL_KEY = "ignore:all"
    IGNORE_SHARD_NAMESPACE = "ignore:shard"

    def initialize(redis)
      @redis = redis
    end

    def ignoring?(shard_id)
      @redis.exists([IGNORE_ALL_KEY, [IGNORE_SHARD_NAMESPACE, shard_id].join(":")])
    end

    def ignore(shard_id, expire: 600)
      @redis.setex([IGNORE_SHARD_NAMESPACE, shard_id].join(":"), expire, "")
    end

    def ignore_all
      @redis.set(IGNORE_ALL_KEY, "")
    end

    def reset_ignore_all
      @redis.del(IGNORE_ALL_KEY)
    end
  end
end
