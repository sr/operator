class CreateDeployRestartServers < ActiveRecord::Migration
  def change
    create_table :deploy_restart_servers do |t|
      t.integer :deploy_id, null: false
      t.integer :server_id
      t.string :datacenter
      t.timestamps null: false
    end

    add_index :deploy_restart_servers, :deploy_id
  end
end
