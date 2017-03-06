class AddDeployTargetIdToServers < ActiveRecord::Migration
  def change
    add_column :servers, :deploy_target_id, :integer, null: false
    add_index :servers, :deploy_target_id
  end
end
