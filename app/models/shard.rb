class Shard < ActiveRecord::Base
  self.abstract_class = true
  establish_connection :shard1
  #self.table_name = "account"
  #self.inheritance_column = :_type_disabled

  def self.tables
    Shard.connection.tables
  end
end
