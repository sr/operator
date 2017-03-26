class RemoveDeployTargetIdFromServers < ActiveRecord::Migration
  def change
    remove_column :servers, :deploy_target_id
  end
end
