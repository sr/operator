class AddNotifiedAt < ActiveRecord::Migration
  def change
    add_column :chef_deploys, :last_notified_at, :timestamp, null: true
  end
end
