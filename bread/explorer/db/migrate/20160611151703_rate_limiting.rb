class RateLimiting < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :rate_limit_transactions_count, :integer,
      null: false, default: 0
    add_column :users, :rate_limit_expires_at, :datetime, null: true
  end
end
