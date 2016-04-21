class DatabaseConfigurationFile
  class Error < StandardError
  end

  class ShardNotFound < Error
    def initialize(id)
      super "config for shard #{id.inspect} not found"
    end
  end

  class DataCenterNotFound < Error
    def initialize(datacenter, shard_id = nil)
      if shard_id
        super "config for shard #{shard_id.inspect} in datacenter #{datacenter.inspect} not found"
      else
        super "config for datacenter #{datacenter.inspect} not found"
      end
    end
  end

  def self.load
    path = Rails.root.join("config", "pi", "#{Rails.env}.yaml")
    auth = Rails.root.join("config", "pi", "#{Rails.env}.auth")
    config = YAML.load_file(path)

    new(config, auth.read.chomp)
  end

  def initialize(config, auth)
    @config = config
    @raw_auth = auth
  end

  def global(datacenter)
    config =
      case datacenter
      when DataCenter::DALLAS
        globals.fetch("dallas")
      when DataCenter::SEATTLE
        globals.fetch("seattle")
      else
        raise DataCenterNotFound, datacenter
      end

    DatabaseConfiguration.new(config, auth)
  end

  def shard(datacenter, id)
    shard = shards[id]

    if !shard
      raise ShardNotFound, id
    end

    config =
      case datacenter
      when DataCenter::DALLAS
        shard.fetch(datacenter)
      when DataCenter::SEATTLE
        shard.fetch(datacenter)
      else
        raise DataCenterNotFound.new(datacenter, id)
      end

    DatabaseConfiguration.new(config, auth)
  end

  private

  def auth
    username, password = load_auth
    DatabaseConfiguration::Auth.new(username, password)
  end

  def load_auth
    parts = @raw_auth.split(":")
    if ![1,2].include?(parts.length)
      raise Error, "auth file is invalid"
    end
    parts
  end

  def shards
    @config.fetch("shards")
  end

  def globals
    @config.fetch("globals").fetch("global")
  end
end
