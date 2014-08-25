class User < ActiveRecord::Base
  self.table_name = 'global_user'
  has_many :queries
end
