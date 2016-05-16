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
    configfile = Rails.root.join("config", "pi", "#{Rails.env}.yml")

    config = YAML.load_file(configfile)
    auth = Rails.application.config.database_configuration

    new(config, auth)
  end

  def initialize(config, auth)
    @config = config
    @auth = auth
  end

  def global(datacenter)
    config =
      case datacenter
      when DataCenter::DALLAS
        globals.fetch(DataCenter::DALLAS)
      when DataCenter::SEATTLE
        globals.fetch(DataCenter::SEATTLE)
      when DataCenter::LOCAL
        globals.fetch(DataCenter::LOCAL)
      else
        raise DataCenterNotFound, datacenter
      end

    DatabaseConfiguration.new(config.fetch(1), auth)
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
      when DataCenter::LOCAL
        globals.fetch(DataCenter::LOCAL)
      else
        raise DataCenterNotFound.new(datacenter, id)
      end

    DatabaseConfiguration.new(config, auth)
  end

  private

  def auth
    config = @auth.fetch(Rails.env.to_s)
    DatabaseConfiguration::Auth.new(
      config["username"],
      config["password"]
    )
  end

  def shards
    @config.fetch("shards")
  end

  def globals
    @config.fetch("globals").fetch("global")
  end
end
