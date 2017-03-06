class DropUnusedServerCountColumnFromDeploys < ActiveRecord::Migration
  def change
    remove_column :deploys, :server_count
  end
end
