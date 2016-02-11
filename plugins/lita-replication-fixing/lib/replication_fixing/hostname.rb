module ReplicationFixing
  class Hostname
    DATACENTER_ABBREVIATIONS = {
      "s" => "seattle",
      "d" => "dallas",
    }.freeze

    attr_reader :prefix, :shard_id, :datacenter

    def initialize(hostname)
      @hostname = hostname
      parse_hostname
    end

    private
    def parse_hostname
      if /\Apardot0-(?<type>dbshard|whoisdb)1-(?<shard_id>\d+)-(?<datacenter>[^-]+)\z/ =~ @hostname
        @prefix = \
          case type
          when "whoisdb"
            "whoisdb"
          else
            "db"
          end

        @shard_id = shard_id.to_i
        @datacenter = datacenter
      elsif /\A(?<type>db|whoisdb)-(?<datacenter_abbreviation>[ds])(?<shard_id>\d+)\z/ =~ @hostname
        @prefix = \
          case type
          when "whoisdb"
            "whoisdb"
          else
            "db"
          end

        @shard_id = shard_id.to_i
        @datacenter = DATACENTER_ABBREVIATIONS.fetch(datacenter_abbreviation)
      end
    end
  end
end
