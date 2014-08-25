class Account < ActiveRecord::Base
  self.table_name = 'global_account'
  has_many :queries
  has_many :account_accesses
end
