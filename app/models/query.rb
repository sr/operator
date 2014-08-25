class Query < ActiveRecord::Base
  self.table_name = 'pardotexplorer_queries'
  belongs_to :account
  belongs_to :user
end
