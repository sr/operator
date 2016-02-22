module ReplicationFixing
  class IgnoreClient
    IGNORE_ALL_KEY = "ignore:all"
    IGNORE_SHARD_NAMESPACE = "ignore:shard"
    IGNORE_SKIPPED_ERRORS_COUNT_KEY = "ignore:skipped_errors_count"

    def initialize(redis)
      @redis = redis
    end

    def ignoring?(shard)
      if @redis.exists(IGNORE_ALL_KEY)
        :all
      elsif @redis.exists([IGNORE_SHARD_NAMESPACE, shard.prefix, shard.shard_id].join(":"))
        :shard
      else
        false
      end
    end

    def ignore(shard, expire: 600)
      @redis.setex([IGNORE_SHARD_NAMESPACE, shard.prefix, shard.shard_id].join(":"), expire, "")
    end

    def reset_ignore(shard)
      @redis.del([IGNORE_SHARD_NAMESPACE, shard.prefix, shard.shard_id].join(":"))
    end

    def ignore_all
      @redis.multi do
        @redis.set(IGNORE_ALL_KEY, "")
        @redis.set(IGNORE_SKIPPED_ERRORS_COUNT_KEY, 0)
      end
    end

    def reset_ignore_all
      @redis.multi do
        @redis.del(IGNORE_ALL_KEY)
        @redis.del(IGNORE_SKIPPED_ERRORS_COUNT_KEY)
      end
    end

    def skipped_errors_count
      @redis.get(IGNORE_SKIPPED_ERRORS_COUNT_KEY).to_i
    end

    def incr_skipped_errors_count
      @redis.incr(IGNORE_SKIPPED_ERRORS_COUNT_KEY).to_i
    end
  end
end
