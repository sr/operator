module ReplicationFixing
  class Shard
    attr_reader :prefix, :id

    def initialize(prefix, id)
      @prefix = prefix
      @id = id
    end

    def to_s
      "#{prefix}-#{id}"
    end

    def ==(other)
      Shard === other && (
        prefix == other.prefix && id == other.id
      )
    end

    def eql?(other)
      Shard === other && (
        prefix == other.prefix && id == other.id
      )
    end

    def hash
      prefix.hash ^ id.hash
    end
  end
end
