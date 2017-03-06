class RenameRepoServerToDeployScenario < ActiveRecord::Migration
  def change
    rename_table :repo_servers, :deploy_scenarios
    add_column :deploy_scenarios, :deploy_target_id, :integer, null: false

    remove_index :deploy_scenarios, [:repo_id, :server_id]
    add_index :deploy_scenarios, [:repo_id, :deploy_target_id, :server_id], unique: true,
      name: "index_deploy_scenarios_on_repo_deploy_server_ids"
  end
end
