require "replication_fixing/shard"

module ReplicationFixing
  class Hostname
    MalformedHostname = Class.new(StandardError)

    DATACENTER_ABBREVIATIONS = {
      "s" => "seattle",
      "d" => "dallas",
    }.freeze

    attr_reader :hostname, :shard, :datacenter

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

    private
    def parse_hostname
      if /\Apardot0-(?<type>dbshard|whoisdb)1-(?<shard_id>\d+)-(?<datacenter>[^-]+)\z/ =~ @hostname
        prefix = \
          case type
          when "whoisdb"
            "whoisdb"
          else
            "db"
          end

        shard_id = shard_id.to_i

        @shard = Shard.new(prefix, shard_id)
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
        @datacenter = DATACENTER_ABBREVIATIONS.fetch(datacenter_abbreviation)
      else
        raise MalformedHostname
      end
    end
  end
end
