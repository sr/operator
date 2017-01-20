class RepositoryConfigFile
  def self.blank
    new(Bread::RepositoryConfig.new)
  end

  def self.parse(encoded)
    new(Bread::RepositoryConfig.decode_json(encoded))
  rescue Google::Protobuf::ParseError
    false
  end

  def initialize(config)
    @config = config
  end

  def high_risk_files
    Array(@config.high_risk_files)
  end

  def required_testing_statuses
    if @config.required_testing_statuses.nil? || @config.required_testing_statuses.empty?
      return Changeling.config.default_required_testing_statuses
    end

    Array(@config.required_testing_statuses)
  end

  def watchlists
    Array(@config.watchlists)
  end

  def to_json
    @config.to_json
  end
end
