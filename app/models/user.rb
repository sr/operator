class User < PardotGlobalExternal
  self.table_name = 'global_user'
  has_many :queries
end
