module ReplicationFixing
  class MessageThrottler
    Entry = Struct.new(:last_sent)

    def initialize(robot:, ttl: 300)
      @robot = robot

      @messages = Hash.new { |h, k| h[k] = {} }
      @ttl = ttl
      @last_cache_clean = Time.now
    end

    def send_message(target, message)
      if room = target.room
        entry = @messages[room][message]
        if !entry || entry.last_sent < (Time.now - @ttl)
          @robot.send_message(target, message).tap { |result|
            @messages[room][message] = Entry.new(Time.now)
            clean_cache
          }
        end
      else
        @robot.send_message(target, message)
      end
    end

    private
    def clean_cache
      now = Time.now
      return unless (now - @last_cache_clean) >= @ttl

      expired_time = (now - @ttl)
      @messages.each do |room, messages|
        messages.delete_if do |message, entry|
          entry.last_sent < expired_time
        end
      end

      @last_cache_clean = now
    end
  end
end
