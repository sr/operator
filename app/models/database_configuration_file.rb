class DatabaseConfigurationFile
  class ShardNotFound < StandardError
    def initialize(id)
      super "config for shard #{id.inspect} not found"
    end
  end

  class DataCenterNotFound < StandardError
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
    config = YAML.load_file(path)
    new(config)
  end

  def initialize(config)
    @config = config
  end

  def global(datacenter)
    config =
      case datacenter
      when DataCenter::DALLAS
        globals.fetch("dallas")
      when DataCenter::SEATTLE
        globals.fetch("seattle")
      else
        raise DataCenterNotFound.new(datacenter)
      end

    DatabaseConfiguration.new(config)
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

    DatabaseConfiguration.new(config)
  end

  private

  def shards
    @config.fetch("shards")
  end

  def globals
    @config.fetch("globals").fetch("global")
  end
end
