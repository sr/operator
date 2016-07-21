module ReplicationFixing
  class MessageThrottler
    THROTTLER_NAMESPACE = "throttler".freeze

    def initialize(robot:, redis:, ttl: 300)
      @robot = robot
      @redis = redis
      @ttl = ttl
    end

    def send_message(target, message)
      if room = target.room
        key = [THROTTLER_NAMESPACE, target.room.to_s, message].join(":")
        unless @redis.exists(key)
          set, = @redis.multi do
            @redis.setnx(key, "")
            @redis.expire(key, @ttl)
          end

          @robot.send_message(target, message) if set
        end
      else
        @robot.send_message(target, message)
      end
    rescue ::Redis::BaseError
      # fail open
      @robot.send_message(target, message)
    end
  end
end
