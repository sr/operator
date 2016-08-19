module ReplicationFixing
  class Shard
    attr_reader :prefix, :shard_id, :datacenter

    def initialize(prefix, shard_id, datacenter)
      @prefix = prefix
      @shard_id = shard_id
      @datacenter = datacenter
    end

    def to_s
      "#{prefix}-#{shard_id}-#{datacenter}"
    end

    def ==(other)
      other.is_a?(Shard) && (prefix == other.prefix && shard_id == other.shard_id && datacenter == other.datacenter)
    end

    def eql?(other)
      other.is_a?(Shard) && (prefix == other.prefix && shard_id == other.shard_id && datacenter == other.datacenter)
    end

    def hash
      prefix.hash ^ shard_id.hash ^ datacenter.hash
    end
  end
end
