class AddRestartServerToDeploys < ActiveRecord::Migration
  def change
    add_column :deploys, :restart_server_id, :integer, null: true
  end
end
