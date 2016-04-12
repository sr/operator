require "replication_fixing/shard"

module ReplicationFixing
  class Hostname
    MalformedHostname = Class.new(StandardError)

    DATACENTER_ABBREVIATIONS = {
      "s" => "seattle",
      "d" => "dallas",
    }.freeze

    attr_reader :hostname, :shard, :cluster_id, :datacenter

    def initialize(hostname)
      @hostname = hostname
      parse_hostname
    end

    def to_s
      @hostname
    end

    def ==(other)
      Hostname === other && hostname == other.hostname
    end

    def eql?(other)
      Hostname === other && hostname == other.hostname
    end

    def hash
      @hostname.hash
    end

    def prefix
      shard.prefix
    end

    def shard_id
      shard.shard_id
    end

    private
    def parse_hostname
      if /\Apardot0-(?<type>dbshard|whoisdb)(?<cluster_id>\d+)-(?<shard_id>\d+)-(?<datacenter>[^-]+)\z/ =~ @hostname
        prefix = \
          case type
          when "whoisdb"
            "whoisdb"
          else
            "db"
          end

        shard_id = shard_id.to_i

        @shard = Shard.new(prefix, shard_id)
        @cluster_id = cluster_id.to_i
        @datacenter = datacenter
      elsif /\A(?<type>db|whoisdb)-(?<datacenter_abbreviation>[ds])(?<shard_id>\d+)\z/ =~ @hostname
        prefix = \
          case type
          when "whoisdb"
            "whoisdb"
          else
            "db"
          end

        shard_id = shard_id.to_i

        @shard = Shard.new(prefix, shard_id)
        @cluster_id = nil
        @datacenter = DATACENTER_ABBREVIATIONS.fetch(datacenter_abbreviation)
      else
        raise MalformedHostname
      end
    end
  end
end
