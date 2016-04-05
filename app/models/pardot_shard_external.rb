class PardotShardExternal < ActiveRecord::Base
  self.abstract_class = true

  # add a class variable to stash our current shard number in
  def self.establish_shard_connection(datacenter, shard_id)
    if datacenter.nil?
      raise ArgumentError, "datacenter can not be nil"
    end

    if shard_id.nil?
      raise ArgumentError, "shard_id can not be nil"
    end

    establish_connection("test_pardot_shard#{shard_id}")
  end

  private

  def after_initialize
    readonly!
  end
end
