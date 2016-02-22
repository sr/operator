module ReplicationFixing
  class Shard
    attr_reader :prefix, :shard_id

    def initialize(prefix, shard_id)
      @prefix = prefix
      @shard_id = shard_id
    end

    def to_s
      "#{prefix}-#{shard_id}"
    end

    def ==(other)
      Shard === other && (
        prefix == other.prefix && shard_id == other.shard_id
      )
    end

    def eql?(other)
      Shard === other && (
        prefix == other.prefix && shard_id == other.shard_id
      )
    end

    def hash
      prefix.hash ^ shard_id.hash
    end
  end
end
