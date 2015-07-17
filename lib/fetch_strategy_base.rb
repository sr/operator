class FetchStrategyBase
  attr_accessor :environment

  def initialize(environment)
    self.environment = environment
  end

  # type should be one of: [:tag, :commit, :branch]
  # value should be the specified type to fetch
  def valid?(value)
    # returns boolean value indicating the combination is valid
    raise "Must be defined by sub-classes"
  end

  # type should be one of: [:tag, :commit, :branch]
  # value should be the specified type to fetch
  def fetch(value)
    # returns path to fetched asset (file or directory)
    raise "Must be defined by sub-classes"
  end

  # can be overriden by sub-classes (no-op otherwise)
  def full_label(label)
    label
  end

  def get_tag_and_hash(label)
    raise "Must be defined by sub-classes"
  end

  def type
    m = self.class.to_s.match(/FetchStrategy(?<type>.*)/)
    m[:type].downcase.to_sym if m
  end

end
