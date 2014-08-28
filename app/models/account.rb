class Account < ActiveRecord::Base
  self.table_name = 'global_account'
  self.inheritance_column = :_type_disabled
  has_many :queries
  has_many :account_accesses

  def descriptive_name
    "#{company} #{shard_id}/#{id}"
  end
end
