class Query < ActiveRecord::Base
  self.table_name = 'pardotexplorer_queries'
  belongs_to :account
  belongs_to :user
  validates :account_id, presence: true, if: :account?

  def account?
    database == "Account"
  end
end
