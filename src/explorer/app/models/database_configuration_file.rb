class DatabaseConfigurationFile
  class Error < StandardError
  end

  class ShardNotFound < Error
    def initialize(id)
      super "config for shard #{id.inspect} not found"
    end
  end

  class DatacenterNotFound < Error
    def initialize(datacenter, shard_id = nil)
      if shard_id
        super "config for shard #{shard_id.inspect} in datacenter #{datacenter.inspect} not found"
      else
        super "config for datacenter #{datacenter.inspect} not found"
      end
    end
  end

  PRIMARY = 1
  SECONDARY = 2

  def self.load
    config_file = Rails.root.join("config", "pi", "#{Rails.env}.yml")
    erb = ERB.new(config_file.read)
    config = YAML.load(erb.result)
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
      when Datacenter::DALLAS, Datacenter::PHOENIX, Datacenter::LOCAL
        globals.fetch(datacenter)
      else
        raise DatacenterNotFound, datacenter
      end
    DatabaseConfiguration.new(config.fetch(SECONDARY), auth)
  end

  def shard(datacenter, id)
    shard = shards[id]

    if !shard
      raise ShardNotFound, id
    end

    config =
      case datacenter
      when Datacenter::DALLAS, Datacenter::PHOENIX, Datacenter::LOCAL
        shard.fetch(datacenter)
      else
        raise DatacenterNotFound.new(datacenter, id)
      end
    DatabaseConfiguration.new(config.fetch(GlobalSetting.secondary_db_id(id)), auth)
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
