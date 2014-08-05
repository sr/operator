class AddServersToDeploy < ActiveRecord::Migration
  def change
    change_table :deploys do |t|
      t.integer :server_count, default: 0
      t.text :servers_used
      t.text :completed_servers
    end
  end
end
